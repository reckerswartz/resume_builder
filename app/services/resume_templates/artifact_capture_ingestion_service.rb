require "json"

module ResumeTemplates
  class ArtifactCaptureIngestionService
    Result = Data.define(:success, :created_artifacts, :reused_artifacts, :errors, :manifest_data, :artifact_root) do
      def success?
        success
      end

      def artifacts
        created_artifacts + reused_artifacts
      end
    end

    def initialize(template:, manifest_path: nil, manifest: nil, artifact_root: nil, capture_signature: nil)
      @template = template
      @manifest_path = manifest_path&.to_s
      @manifest = manifest
      @artifact_root = artifact_root&.to_s
      @capture_signature = capture_signature.to_s.presence
      @created_artifacts = []
      @reused_artifacts = []
    end

    def call
      @manifest_data = load_manifest_data
      errors = manifest_errors
      return failure(errors) if errors.any?

      ActiveRecord::Base.transaction do
        source_capture = ingest_source_capture
        reference_design = ingest_reference_design(parent_artifact: source_capture)
        ingest_search_capture(parent_artifact: source_capture)
        ingest_project_capture(parent_artifact: reference_design)
        ingest_module_captures(parent_artifact: reference_design)
        ingest_design_notes(parent_artifact: reference_design)
      end

      Result.new(
        success: true,
        created_artifacts: created_artifacts,
        reused_artifacts: reused_artifacts,
        errors: [],
        manifest_data: manifest_data,
        artifact_root: resolved_artifact_root&.to_s
      )
    rescue JSON::ParserError
      failure([ "Manifest could not be parsed" ])
    rescue Errno::ENOENT => error
      failure([ "Capture file could not be found: #{error.message}" ])
    rescue ActiveRecord::RecordInvalid => error
      failure([ error.record.errors.full_messages.to_sentence ])
    end

    private
      attr_reader :artifact_root, :capture_signature, :created_artifacts, :manifest, :manifest_data, :manifest_path, :reused_artifacts, :template

      def load_manifest_data
        raw_manifest = if manifest.present?
          manifest.to_h
        else
          JSON.parse(File.read(manifest_path))
        end

        raw_manifest.deep_stringify_keys
      end

      def manifest_errors
        errors = []
        errors << "reference_key is required" if manifest_data["reference_key"].blank?
        errors << "source_type is required" if manifest_data["source_type"].blank?
        errors << "source_url is required" if manifest_data["source_url"].blank?

        referenced_files.each do |referenced_file|
          next if referenced_file[:path].blank? || File.exist?(referenced_file[:path])

          errors << "Referenced capture file is missing: #{referenced_file[:filename]}"
        end

        errors
      end

      def ingest_source_capture
        ingest_artifact(
          artifact_type: "source_capture",
          name: "#{display_title} capture bundle",
          description: "Stored raw capture manifest and file inventory for #{display_title}.",
          content: JSON.pretty_generate(manifest_data),
          metadata: source_metadata.merge(
            "captured_files" => Array(manifest_data["captured_files"]),
            "search_artifact" => manifest_data["search_artifact"],
            "project_artifact" => manifest_data["project_artifact"],
            "resumebuilder_reference_urls" => Array(manifest_data["resumebuilder_reference_urls"]),
            "module_urls" => Array(manifest_data["module_urls"]),
            "manifest_path" => manifest_path
          ),
          source_signature: artifact_signature("source-capture"),
          source_url: manifest_data["source_url"],
          version_label: capture_version_label,
          attachment_name: :artifact_file,
          attachment_path: manifest_path,
          lineage_kind: "source"
        )
      end

      def ingest_reference_design(parent_artifact:)
        ingest_artifact(
          artifact_type: "reference_design",
          name: "#{display_title} reference design",
          description: "Canonical reference-design metadata captured from #{manifest_data["source_type"].to_s.titleize} for #{display_title}.",
          content: reference_design_content,
          metadata: source_metadata.merge(
            "module_urls" => Array(manifest_data["module_urls"]),
            "resumebuilder_reference_urls" => Array(manifest_data["resumebuilder_reference_urls"]),
            "project_artifact" => manifest_data["project_artifact"],
            "search_artifact" => manifest_data["search_artifact"]
          ),
          source_signature: artifact_signature("reference-design"),
          source_url: manifest_data["source_url"],
          version_label: capture_version_label,
          parent_artifact: parent_artifact,
          lineage_kind: "source"
        )
      end

      def ingest_search_capture(parent_artifact:)
        return if manifest_data["search_artifact"].blank?

        ingest_reference_image(
          filename: manifest_data["search_artifact"],
          name: "#{display_title} search results",
          description: "Captured search-results context for #{display_title}.",
          artifact_role: "search_results",
          parent_artifact: parent_artifact,
          signature_suffix: "search-results"
        )
      end

      def ingest_project_capture(parent_artifact:)
        return if manifest_data["project_artifact"].blank?

        ingest_reference_image(
          filename: manifest_data["project_artifact"],
          name: "#{display_title} project page",
          description: "Captured full Behance project-page reference for #{display_title}.",
          artifact_role: "project_page",
          parent_artifact: parent_artifact,
          signature_suffix: "project-page"
        )
      end

      def ingest_module_captures(parent_artifact:)
        module_filenames.each_with_index.map do |filename, index|
          ingest_reference_image(
            filename: filename,
            name: "#{display_title} module #{format('%02d', index + 1)}",
            description: "Captured project module #{index + 1} for #{display_title}.",
            artifact_role: "module_capture",
            module_index: index + 1,
            module_url: Array(manifest_data["module_urls"])[index],
            parent_artifact: parent_artifact,
            signature_suffix: "module-#{format('%02d', index + 1)}"
          )
        end.compact
      end

      def ingest_design_notes(parent_artifact:)
        notes = Array(manifest_data["notes"]).compact.reject(&:blank?)
        return if notes.blank?

        ingest_artifact(
          artifact_type: "design_note",
          name: "#{display_title} capture notes",
          description: "Captured reference notes recorded during artifact collection for #{display_title}.",
          content: notes.map { |note| "- #{note}" }.join("\n"),
          metadata: source_metadata.merge(
            "note_count" => notes.size,
            "resumebuilder_reference_urls" => Array(manifest_data["resumebuilder_reference_urls"])
          ),
          source_signature: artifact_signature("design-note"),
          source_url: manifest_data["source_url"],
          version_label: capture_version_label,
          parent_artifact: parent_artifact,
          lineage_kind: "documentation"
        )
      end

      def ingest_reference_image(filename:, name:, description:, artifact_role:, parent_artifact:, signature_suffix:, module_index: nil, module_url: nil)
        ingest_artifact(
          artifact_type: "reference_image",
          name: name,
          description: description,
          content: "",
          metadata: source_metadata.merge(
            "artifact_role" => artifact_role,
            "source_filename" => filename,
            "module_index" => module_index,
            "module_url" => module_url
          ),
          source_signature: artifact_signature("reference-image", signature_suffix),
          source_url: module_url.presence || manifest_data["source_url"],
          version_label: capture_version_label,
          parent_artifact: parent_artifact,
          attachment_name: :reference_image,
          attachment_path: file_path_for(filename),
          lineage_kind: "source"
        )
      end

      def ingest_artifact(artifact_type:, name:, description:, content:, metadata:, source_signature:, source_url:, version_label:, parent_artifact: nil, attachment_name: nil, attachment_path: nil, lineage_kind: nil)
        existing_artifact = template.template_artifacts.find_by(source_signature: source_signature)
        if existing_artifact.present?
          reused_artifacts << existing_artifact
          return existing_artifact
        end

        artifact = template.template_artifacts.new(
          artifact_type: artifact_type,
          name: name,
          description: description,
          content: content,
          metadata: metadata,
          version_label: version_label,
          status: "active",
          parent_artifact: parent_artifact,
          source_url: source_url,
          source_signature: source_signature,
          lineage_kind: lineage_kind
        )
        attach_file(artifact, attachment_name, attachment_path) if attachment_name.present? && attachment_path.present?
        artifact.save!
        created_artifacts << artifact
        artifact
      end

      def attach_file(artifact, attachment_name, attachment_path)
        artifact.public_send(attachment_name).attach(
          io: StringIO.new(File.binread(attachment_path)),
          filename: File.basename(attachment_path),
          content_type: Marcel::MimeType.for(Pathname.new(attachment_path), name: File.basename(attachment_path))
        )
      end

      def source_metadata
        {
          "reference_key" => manifest_data["reference_key"],
          "source_type" => manifest_data["source_type"],
          "reference_source_url" => manifest_data["source_url"],
          "source_title" => display_title,
          "captured_at" => manifest_data["captured_at"],
          "capture_signature" => base_capture_signature
        }
      end

      def reference_design_content
        [
          "Source title: #{display_title}",
          "Source type: #{manifest_data["source_type"]}",
          "Source URL: #{manifest_data["source_url"]}",
          ("Captured at: #{manifest_data["captured_at"]}" if manifest_data["captured_at"].present?),
          ("Reference key: #{manifest_data["reference_key"]}" if manifest_data["reference_key"].present?)
        ].compact.join("\n")
      end

      def referenced_files
        files = []
        files << { filename: manifest_data["search_artifact"], path: file_path_for(manifest_data["search_artifact"]) } if manifest_data["search_artifact"].present?
        files << { filename: manifest_data["project_artifact"], path: file_path_for(manifest_data["project_artifact"]) } if manifest_data["project_artifact"].present?
        module_filenames.each do |filename|
          files << { filename: filename, path: file_path_for(filename) }
        end
        files
      end

      def module_filenames
        Array(manifest_data["captured_files"]).grep(/\Amodule-\d+\./).sort
      end

      def file_path_for(filename)
        return if filename.blank? || resolved_artifact_root.blank?

        resolved_artifact_root.join(filename).to_s
      end

      def resolved_artifact_root
        @resolved_artifact_root ||= begin
          if artifact_root.present?
            Pathname.new(artifact_root)
          elsif manifest_path.present?
            Pathname.new(manifest_path).dirname
          end
        end
      end

      def display_title
        manifest_data["source_title"].presence || manifest_data["reference_key"].to_s.tr("-", " ").titleize
      end

      def capture_version_label
        manifest_data["captured_at"].presence || Time.current.to_date.iso8601
      end

      def base_capture_signature
        @base_capture_signature ||= normalize_identifier_parts(
          capture_signature.presence || manifest_data["capture_signature"].presence || manifest_data["source_type"],
          manifest_data["reference_key"]
        )
      end

      def artifact_signature(*suffixes)
        normalize_identifier_parts(base_capture_signature, *suffixes)
      end

      def normalize_identifier_parts(*parts)
        parts.compact.map { |part| part.to_s.tr("_", "-") }.join("-").parameterize(separator: "-")
      end

      def failure(errors)
        Result.new(
          success: false,
          created_artifacts: created_artifacts,
          reused_artifacts: reused_artifacts,
          errors: Array(errors),
          manifest_data: manifest_data,
          artifact_root: resolved_artifact_root&.to_s
        )
      end
  end
end
