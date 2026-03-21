require "rails_helper"

RSpec.describe ResumeTemplates::ImplementationPromotionService do
  describe "#call" do
    it "promotes a reviewed draft candidate to validated and records a version snapshot" do
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
      validation_run = create(
        :template_validation_run,
        template: template,
        template_implementation: draft_candidate,
        reference_artifact: source_artifact,
        validation_type: "manual_review",
        status: "passed",
        validator_name: user.email_address
      )

      result = described_class.new(template: template, template_implementation: draft_candidate, user: user).call

      expect(result).to be_success
      expect(result).to be_promoted
      expect(result.template_implementation.reload.status).to eq("validated")
      expect(result.template_implementation.validated_at).to eq(validation_run.validated_at)
      expect(result.template_implementation.metadata).to include(
        "promotion_mode" => "admin_validation_promotion",
        "promotion_validation_run_identifier" => validation_run.identifier,
        "promoted_by_user_id" => user.id
      )
      expect(result.promotion_artifact).to be_persisted
      expect(result.promotion_artifact.artifact_type).to eq("version_snapshot")
      expect(result.promotion_artifact.metadata).to include(
        "artifact_role" => "validated_implementation_snapshot",
        "promotion_validation_run_identifier" => validation_run.identifier
      )
    end

    it "rejects promotion when a draft candidate has no passed validation run" do
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
      create(
        :template_validation_run,
        template: template,
        template_implementation: draft_candidate,
        reference_artifact: source_artifact,
        validation_type: "manual_review",
        status: "needs_review"
      )

      result = described_class.new(template: template, template_implementation: draft_candidate, user: user).call

      expect(result).not_to be_success
      expect(result.error_message).to eq("Record a passed validation run before promoting this draft implementation.")
      expect(draft_candidate.reload.status).to eq("draft")
      expect(template.template_artifacts.where(artifact_type: "version_snapshot")).to be_empty
    end
  end
end
