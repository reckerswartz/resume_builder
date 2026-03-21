module ResumeTemplates
  class ImplementationCandidateCreationService
    Result = Data.define(:template, :template_implementation, :source_artifact, :error_message, :created) do
      def success?
        error_message.blank? && template_implementation.present?
      end

      def created?
        created
      end
    end

    def initialize(template:, user:, source_artifact_id: nil, renderer_family: nil, notes: nil)
      @template = template
      @user = user
      @source_artifact_id = source_artifact_id
      @renderer_family = renderer_family
      @notes = notes
    end

    def call
      artifact = resolved_source_artifact
      return failure(error_message: missing_source_artifact_message) unless artifact.present?
      return failure(source_artifact: artifact, error_message: ineligible_source_artifact_message) unless eligible_source_artifact?(artifact)

      draft_candidate = existing_draft_candidate_for(artifact)
      return success(template_implementation: draft_candidate, source_artifact: artifact, created: false) if draft_candidate.present?

      created_candidate = nil
      created_candidate_record = false

      ActiveRecord::Base.transaction do
        template.with_lock do
          draft_candidate = existing_draft_candidate_for(artifact)
          if draft_candidate.present?
            created_candidate = draft_candidate
            next
          end

          created_candidate = template.template_implementations.create!(
            source_artifact: artifact,
            name: next_candidate_name,
            status: "draft",
            renderer_family: candidate_renderer_family(artifact),
            render_profile: baseline_render_profile,
            notes: candidate_notes(artifact),
            metadata: candidate_metadata(artifact)
          )
          create_snapshot_artifact!(source_artifact: artifact, template_implementation: created_candidate)
          created_candidate_record = true
        end
      end

      success(
        template_implementation: created_candidate,
        source_artifact: artifact,
        created: created_candidate_record
      )
    rescue ActiveRecord::RecordInvalid => error
      failure(source_artifact: artifact, error_message: error.record.errors.full_messages.to_sentence)
    end

    private
      attr_reader :notes, :renderer_family, :source_artifact_id, :template, :user

      def resolved_source_artifact
        @resolved_source_artifact ||= begin
          return selected_source_artifact if source_artifact_id.present?

          template.template_artifacts.active.source_material.order(validated_at: :desc, created_at: :desc).first
        end
      end

      def selected_source_artifact
        template.template_artifacts.find_by(id: source_artifact_id)
      end

      def eligible_source_artifact?(artifact)
        artifact.active? && artifact.source?
      end

      def existing_draft_candidate_for(artifact)
        template.template_implementations.where(status: "draft", source_artifact: artifact).most_recent_first.find do |candidate|
          candidate.renderer_family == candidate_renderer_family(artifact) &&
            candidate.effective_render_profile == baseline_render_profile
        end
      end

      def baseline_render_profile
        @baseline_render_profile ||= template.render_layout_config.deep_dup
      end

      def candidate_renderer_family(artifact)
        renderer_family.presence ||
          artifact.metadata["renderer_family"].presence ||
          artifact.metadata["layout_family"].presence ||
          baseline_render_profile["family"].presence ||
          template.layout_family
      end

      def next_candidate_name
        "#{template.name} candidate #{template.template_implementations.count + 1}"
      end

      def candidate_notes(artifact)
        notes.presence || "Draft candidate created from #{artifact.name}."
      end

      def create_snapshot_artifact!(source_artifact:, template_implementation:)
        template.template_artifacts.create!(
          artifact_type: "implementation_snapshot",
          lineage_kind: "derived",
          parent_artifact: source_artifact,
          name: template_implementation.name,
          description: "Draft implementation snapshot.",
          content: JSON.pretty_generate(template_implementation.effective_render_profile),
          version_label: template_implementation.identifier,
          metadata: snapshot_metadata(source_artifact: source_artifact, template_implementation: template_implementation)
        )
      end

      def candidate_metadata(artifact)
        {
          "creation_mode" => "admin_candidate",
          "created_by_user_id" => user&.id,
          "created_by_user_email" => user&.email_address,
          "source_artifact_identifier" => artifact.identifier,
          "source_signature" => artifact.source_signature,
          "reference_source_url" => artifact.reference_source_url,
          "baseline_profile_source" => template.current_implementation.present? ? "current_implementation" : "template_layout_config",
          "baseline_implementation_identifier" => template.current_implementation&.identifier,
          "created_at" => Time.current.iso8601
        }.compact
      end

      def snapshot_metadata(source_artifact:, template_implementation:)
        {
          "artifact_role" => "draft_candidate_snapshot",
          "creation_mode" => "admin_candidate",
          "template_implementation_id" => template_implementation.id,
          "template_implementation_identifier" => template_implementation.identifier,
          "source_artifact_identifier" => source_artifact.identifier,
          "source_signature" => source_artifact.source_signature,
          "renderer_family" => template_implementation.renderer_family,
          "status" => template_implementation.status,
          "created_by_user_id" => user&.id,
          "created_by_user_email" => user&.email_address,
          "created_at" => Time.current.iso8601
        }.compact
      end

      def missing_source_artifact_message
        return "Select an active source artifact before creating a draft candidate." if source_artifact_id.present?

        "Capture at least one active source artifact before creating a draft candidate."
      end

      def ineligible_source_artifact_message
        "Selected artifact must be an active source artifact."
      end

      def success(template_implementation:, source_artifact:, created:)
        Result.new(
          template: template,
          template_implementation: template_implementation,
          source_artifact: source_artifact,
          error_message: nil,
          created: created
        )
      end

      def failure(error_message:, source_artifact: nil)
        Result.new(
          template: template,
          template_implementation: nil,
          source_artifact: source_artifact,
          error_message: error_message,
          created: false
        )
      end
  end
end
