require "rails_helper"

RSpec.describe ResumeTemplates::SeedBaselineResolver do
  describe "#call" do
    it "returns the matching active seed snapshot for the current seeded implementation" do
      template = create(:template, slug: "modern")
      source_artifact = create(
        :template_artifact,
        template: template,
        artifact_type: "reference_design",
        lineage_kind: "source",
        name: "Behance capture"
      )
      implementation = create(
        :template_implementation,
        template: template,
        source_artifact: source_artifact,
        status: "seeded",
        renderer_family: template.layout_family,
        render_profile: template.render_layout_config,
        validated_at: Time.zone.local(2026, 3, 21, 18, 15),
        seeded_at: Time.zone.local(2026, 3, 21, 19, 0)
      )
      seed_artifact = create(
        :template_artifact,
        template: template,
        artifact_type: "seed_snapshot",
        lineage_kind: "derived",
        parent_artifact: source_artifact,
        name: implementation.name,
        version_label: "#{implementation.identifier}-seeded",
        metadata: {
          "artifact_role" => "seeded_implementation_snapshot",
          "template_implementation_identifier" => implementation.identifier,
          "source_artifact_identifier" => source_artifact.identifier
        }
      )

      result = described_class.new(template: template).call

      expect(result).to include(
        available: true,
        ready: true,
        missing_artifact: false,
        implementation_identifier: implementation.identifier,
        artifact_identifier: seed_artifact.identifier,
        artifact_version_label: "#{implementation.identifier}-seeded",
        source_artifact_identifier: source_artifact.identifier,
        seeded_at: Time.zone.local(2026, 3, 21, 19, 0)
      )
      expect(result[:artifact_created_at]).to eq(seed_artifact.created_at)
    end

    it "reports a missing artifact when the current implementation is seeded without a seed snapshot" do
      template = create(:template, slug: "modern")
      implementation = create(
        :template_implementation,
        template: template,
        status: "seeded",
        renderer_family: template.layout_family,
        render_profile: template.render_layout_config,
        validated_at: Time.zone.local(2026, 3, 21, 18, 15),
        seeded_at: Time.zone.local(2026, 3, 21, 19, 0)
      )

      result = described_class.new(template: template).call

      expect(result).to include(
        available: true,
        ready: false,
        missing_artifact: true,
        implementation_identifier: implementation.identifier,
        artifact_identifier: nil
      )
    end

    it "returns unavailable when the current implementation is not seeded" do
      template = create(:template, slug: "modern")
      create(
        :template_implementation,
        template: template,
        status: "stable",
        renderer_family: template.layout_family,
        render_profile: template.render_layout_config,
        validated_at: Time.zone.local(2026, 3, 21, 18, 15)
      )

      result = described_class.new(template: template).call

      expect(result).to include(
        available: false,
        ready: false,
        missing_artifact: false,
        implementation_identifier: nil,
        artifact_identifier: nil
      )
    end
  end
end
