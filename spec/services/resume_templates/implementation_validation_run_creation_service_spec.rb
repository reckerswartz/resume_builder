require "rails_helper"

RSpec.describe ResumeTemplates::ImplementationValidationRunCreationService do
  describe "#call" do
    it "creates a validation run and validation artifact for a draft implementation" do
      template = create(:template, name: "Editorial Split", slug: "editorial-split")
      user = create(:user, :admin)
      source_artifact = create(
        :template_artifact,
        template: template,
        artifact_type: "reference_design",
        lineage_kind: "source",
        name: "Behance capture"
      )
      draft_candidate = create(
        :template_implementation,
        template: template,
        source_artifact: source_artifact,
        status: "draft",
        renderer_family: template.layout_family,
        render_profile: template.render_layout_config
      )

      result = described_class.new(
        template: template,
        template_implementation: draft_candidate,
        user: user,
        validation_type: "manual_review",
        status: "passed"
      ).call

      expect(result).to be_success
      expect(result.template_validation_run).to be_persisted
      expect(result.template_validation_run.template_implementation).to eq(draft_candidate)
      expect(result.template_validation_run.reference_artifact).to eq(source_artifact)
      expect(result.template_validation_run.status).to eq("passed")
      expect(result.template_validation_run.validator_name).to eq(user.email_address)
      expect(result.template_validation_run.validated_at).to be_present
      expect(result.validation_artifact).to be_persisted
      expect(result.validation_artifact.artifact_type).to eq("validation_report")
      expect(result.validation_artifact.lineage_kind).to eq("validation")
      expect(result.validation_artifact.parent_artifact).to eq(source_artifact)
      expect(result.validation_artifact.metadata).to include(
        "artifact_role" => "implementation_validation_result",
        "template_validation_run_identifier" => result.template_validation_run.identifier
      )
    end

    it "records multiple validation runs for the same implementation with unique identifiers" do
      template = create(:template, name: "Editorial Split", slug: "editorial-split")
      user = create(:user, :admin)
      source_artifact = create(:template_artifact, template: template, artifact_type: "reference_design", lineage_kind: "source", name: "Behance capture")
      draft_candidate = create(
        :template_implementation,
        template: template,
        source_artifact: source_artifact,
        status: "draft",
        renderer_family: template.layout_family,
        render_profile: template.render_layout_config
      )

      first_result = described_class.new(
        template: template,
        template_implementation: draft_candidate,
        user: user,
        validation_type: "manual_review",
        status: "needs_review"
      ).call
      second_result = described_class.new(
        template: template,
        template_implementation: draft_candidate,
        user: user,
        validation_type: "manual_review",
        status: "passed"
      ).call

      expect(first_result).to be_success
      expect(second_result).to be_success
      expect(first_result.template_validation_run.identifier).not_to eq(second_result.template_validation_run.identifier)
      expect(draft_candidate.template_validation_runs.count).to eq(2)
    end
  end
end
