require "rails_helper"

RSpec.describe ResumeTemplates::ImplementationCandidateCreationService do
  describe "#call" do
    it "creates a draft candidate and a derived implementation snapshot from a source artifact" do
      template = create(:template, name: "Editorial Split", slug: "editorial-split")
      user = create(:user, :admin)
      source_artifact = create(
        :template_artifact,
        template: template,
        artifact_type: "reference_design",
        lineage_kind: "source",
        name: "Behance capture",
        metadata: { "reference_source_url" => "https://www.behance.net/gallery/245736819/Resume-Cv-Template" }
      )

      result = described_class.new(template: template, user: user, source_artifact_id: source_artifact.id).call

      expect(result).to be_success
      expect(result).to be_created
      expect(result.template_implementation).to be_persisted
      expect(result.template_implementation.status).to eq("draft")
      expect(result.template_implementation.source_artifact).to eq(source_artifact)
      expect(result.template_implementation.render_profile).to eq(template.render_layout_config)
      expect(result.template_implementation.metadata).to include(
        "creation_mode" => "admin_candidate",
        "created_by_user_id" => user.id,
        "source_artifact_identifier" => source_artifact.identifier,
        "source_signature" => source_artifact.source_signature
      )

      snapshot_artifact = template.template_artifacts.find_by(artifact_type: "implementation_snapshot")
      expect(snapshot_artifact).to be_present
      expect(snapshot_artifact.parent_artifact).to eq(source_artifact)
      expect(snapshot_artifact.metadata).to include(
        "artifact_role" => "draft_candidate_snapshot",
        "template_implementation_identifier" => result.template_implementation.identifier
      )
    end

    it "reuses an existing matching draft candidate for the same source artifact" do
      template = create(:template, name: "Editorial Split", slug: "editorial-split")
      user = create(:user, :admin)
      source_artifact = create(:template_artifact, template: template, artifact_type: "reference_design", lineage_kind: "source", name: "Behance capture")
      existing_candidate = create(
        :template_implementation,
        template: template,
        source_artifact: source_artifact,
        status: "draft",
        renderer_family: template.layout_family,
        render_profile: template.render_layout_config,
        notes: "Existing draft"
      )

      expect do
        result = described_class.new(template: template, user: user, source_artifact_id: source_artifact.id).call

        expect(result).to be_success
        expect(result).not_to be_created
        expect(result.template_implementation).to eq(existing_candidate)
      end.not_to change(TemplateImplementation, :count)
    end

    it "fails when the selected artifact is not an active source artifact" do
      template = create(:template)
      user = create(:user, :admin)
      note_artifact = create(:template_artifact, template: template, artifact_type: "design_note", lineage_kind: "documentation", name: "Capture notes")

      result = described_class.new(template: template, user: user, source_artifact_id: note_artifact.id).call

      expect(result).not_to be_success
      expect(result.error_message).to eq("Selected artifact must be an active source artifact.")
    end
  end
end
