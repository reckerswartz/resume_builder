require "rails_helper"
require "base64"
require "json"
require "tmpdir"

RSpec.describe ResumeTemplates::ArtifactCaptureIngestionService, type: :service do
  TINY_PNG_BASE64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO2Z7mQAAAAASUVORK5CYII="

  let(:template) { create(:template, slug: "editorial-split") }

  def with_capture_bundle(manifest_overrides: {})
    Dir.mktmpdir do |dir|
      root = Pathname.new(dir)
      filenames = [
        "behance-cv-template-search-results.png",
        "project-page-full.png",
        "module-01.png",
        "module-02.png"
      ]

      filenames.each do |filename|
        File.binwrite(root.join(filename), Base64.decode64(TINY_PNG_BASE64))
      end

      manifest = {
        "reference_key" => "resume-cv-template-reuix-studio",
        "source_type" => "behance",
        "source_url" => "https://www.behance.net/gallery/245736819/Resume-Cv-Template",
        "source_title" => "Resume Cv Template",
        "captured_at" => "2026-03-20",
        "search_artifact" => "behance-cv-template-search-results.png",
        "project_artifact" => "project-page-full.png",
        "module_urls" => [
          "https://cdn.example.com/module-01.jpeg",
          "https://cdn.example.com/module-02.jpeg"
        ],
        "captured_files" => [
          ".keep",
          "project-page-full.png",
          "module-01.png",
          "module-02.png",
          "behance-cv-template-search-results.png"
        ],
        "resumebuilder_reference_urls" => [
          "https://www.resumebuilder.com/resume-templates/"
        ],
        "notes" => [
          "Behance artifacts were captured with Playwright into the local workflow cache.",
          "ResumeBuilder.com template discovery notes were gathered from the public templates page."
        ]
      }.deep_merge(manifest_overrides.deep_stringify_keys)

      manifest_path = root.join("manifest.json")
      manifest_path.write(JSON.pretty_generate(manifest))

      yield root, manifest_path, manifest
    end
  end

  describe "#call" do
    it "creates immutable source artifacts with attachments and lineage from a Behance manifest" do
      result = nil
      manifest = nil

      expect do
        with_capture_bundle do |root, manifest_path, bundle_manifest|
          manifest = bundle_manifest
          result = described_class.new(template: template, manifest_path: manifest_path.to_s).call

          expect(result).to be_success
          expect(result.errors).to be_empty
          expect(result.artifact_root).to eq(root.to_s)
        end
      end.to change(TemplateArtifact, :count).by(7)

      source_capture = template.template_artifacts.find_by!(artifact_type: "source_capture")
      reference_design = template.template_artifacts.find_by!(artifact_type: "reference_design")
      design_note = template.template_artifacts.find_by!(artifact_type: "design_note")
      project_image = template.template_artifacts.find_by!(artifact_type: "reference_image", name: "Resume Cv Template project page")
      search_image = template.template_artifacts.find_by!(artifact_type: "reference_image", name: "Resume Cv Template search results")
      module_image = template.template_artifacts.find_by!(artifact_type: "reference_image", name: "Resume Cv Template module 01")

      expect(source_capture).to be_source
      expect(source_capture.immutable_source).to eq(true)
      expect(source_capture.artifact_file).to be_attached
      expect(source_capture.reference_source_url).to eq(manifest.fetch("source_url"))
      expect(source_capture.metadata.fetch("captured_files")).to include("module-01.png")

      expect(reference_design.parent_artifact).to eq(source_capture)
      expect(reference_design).to be_source

      expect(design_note.parent_artifact).to eq(reference_design)
      expect(design_note).to be_documentation
      expect(design_note.content).to include("Behance artifacts were captured with Playwright")

      expect(search_image.parent_artifact).to eq(source_capture)
      expect(search_image.reference_image).to be_attached
      expect(search_image.metadata.fetch("artifact_role")).to eq("search_results")

      expect(project_image.parent_artifact).to eq(reference_design)
      expect(project_image.reference_image).to be_attached
      expect(project_image.metadata.fetch("artifact_role")).to eq("project_page")

      expect(module_image.parent_artifact).to eq(reference_design)
      expect(module_image.reference_image).to be_attached
      expect(module_image.metadata.fetch("artifact_role")).to eq("module_capture")
      expect(module_image.metadata.fetch("module_index")).to eq(1)
      expect(module_image.metadata.fetch("module_url")).to eq("https://cdn.example.com/module-01.jpeg")

      expect(result.created_artifacts.size).to eq(7)
      expect(result.reused_artifacts).to be_empty
    end

    it "is idempotent and reuses existing source artifacts for the same capture signature" do
      first_result = nil
      second_result = nil

      with_capture_bundle do |_root, manifest_path, _manifest|
        first_result = described_class.new(
          template: template,
          manifest_path: manifest_path.to_s,
          capture_signature: "behance:245736819:resume-cv-template:editorial-split"
        ).call

        expect do
          second_result = described_class.new(
            template: template,
            manifest_path: manifest_path.to_s,
            capture_signature: "behance:245736819:resume-cv-template:editorial-split"
          ).call
        end.not_to change(TemplateArtifact, :count)
      end

      expect(first_result).to be_success
      expect(second_result).to be_success
      expect(second_result.created_artifacts).to be_empty
      expect(second_result.reused_artifacts.size).to eq(first_result.created_artifacts.size)
      expect(second_result.reused_artifacts.map(&:source_signature).uniq.size).to eq(first_result.created_artifacts.size)
    end

    it "fails when a referenced capture file is missing" do
      result = nil

      expect do
        with_capture_bundle do |root, _manifest_path, manifest|
          File.delete(root.join("project-page-full.png"))

          result = described_class.new(
            template: template,
            manifest: manifest,
            artifact_root: root.to_s
          ).call
        end
      end.not_to change(TemplateArtifact, :count)

      expect(result).not_to be_success
      expect(result.errors).to include("Referenced capture file is missing: project-page-full.png")
    end
  end
end
