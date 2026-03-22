require "rails_helper"

RSpec.describe ResumeTemplates::ImplementationArchivalService do
  describe "#call" do
    it "archives a superseded render-ready implementation and records archival metadata" do
      template = create(:template, name: "Editorial Split", slug: "editorial-split")
      user = create(:user, :admin)
      source_artifact = create(
        :template_artifact,
        template: template,
        artifact_type: "reference_design",
        lineage_kind: "source",
        name: "Behance capture"
      )
      create(
        :template_implementation,
        template: template,
        source_artifact: source_artifact,
        status: "stable",
        renderer_family: template.layout_family,
        render_profile: template.render_layout_config,
        validated_at: Time.zone.local(2026, 3, 21, 19, 15)
      )
      superseded_implementation = create(
        :template_implementation,
        template: template,
        source_artifact: source_artifact,
        status: "validated",
        renderer_family: template.layout_family,
        render_profile: template.render_layout_config,
        validated_at: Time.zone.local(2026, 3, 20, 18, 0)
      )

      result = described_class.new(template: template, template_implementation: superseded_implementation, user: user).call

      expect(result).to be_success
      expect(result).to be_archived
      expect(result.template_implementation.reload.status).to eq("archived")
      expect(result.template_implementation.metadata).to include(
        "archive_mode" => "admin_history_cleanup",
        "archived_from_status" => "validated",
        "archived_by_user_id" => user.id,
        "archived_by_user_email" => user.email_address
      )
      expect(result.template_implementation.metadata["archived_at"]).to be_present
      expect(result.template_implementation.validated_at).to eq(Time.zone.local(2026, 3, 20, 18, 0))
    end

    it "returns a successful no-op result when the implementation is already archived" do
      template = create(:template, name: "Editorial Split", slug: "editorial-split")
      user = create(:user, :admin)
      archived_implementation = create(
        :template_implementation,
        template: template,
        status: "archived",
        renderer_family: template.layout_family,
        render_profile: template.render_layout_config,
        metadata: { "archived_at" => Time.current.iso8601, "archived_from_status" => "stable" },
        validated_at: Time.zone.local(2026, 3, 20, 18, 0)
      )

      result = described_class.new(template: template, template_implementation: archived_implementation, user: user).call

      expect(result).to be_success
      expect(result).not_to be_archived
      expect(result.template_implementation.reload.status).to eq("archived")
    end

    it "rejects archiving the current implementation" do
      template = create(:template, name: "Editorial Split", slug: "editorial-split")
      user = create(:user, :admin)
      current_implementation = create(
        :template_implementation,
        template: template,
        status: "seeded",
        renderer_family: template.layout_family,
        render_profile: template.render_layout_config,
        seeded_at: Time.zone.local(2026, 3, 21, 20, 0),
        validated_at: Time.zone.local(2026, 3, 21, 19, 15)
      )

      result = described_class.new(template: template, template_implementation: current_implementation, user: user).call

      expect(result).not_to be_success
      expect(result.error_message).to eq("The current implementation cannot be archived from this flow.")
      expect(current_implementation.reload.status).to eq("seeded")
    end
  end
end
