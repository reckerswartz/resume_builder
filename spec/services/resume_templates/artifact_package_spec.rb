require "rails_helper"

RSpec.describe ResumeTemplates::ArtifactPackage do
  describe "#call" do
    it "packages source, derived, documentation, validation, and implementation context" do
      template = create(:template, slug: "modern")
      source_artifact = create(
        :template_artifact,
        template: template,
        artifact_type: "reference_design",
        lineage_kind: "source",
        metadata: { "reference_source_url" => "https://behance.net/example" }
      )
      create(:template_artifact, template: template, artifact_type: "implementation_snapshot", lineage_kind: "derived")
      create(:template_artifact, template: template, artifact_type: "design_note", lineage_kind: "documentation")
      create(:template_artifact, template: template, artifact_type: "validation_report", lineage_kind: "validation")
      implementation = create(
        :template_implementation,
        template: template,
        source_artifact: source_artifact,
        status: "stable",
        renderer_family: "modern",
        render_profile: template.normalized_layout_config,
        validated_at: Time.zone.local(2026, 3, 21, 18, 0)
      )
      historical_implementation = create(
        :template_implementation,
        template: template,
        source_artifact: source_artifact,
        status: "validated",
        renderer_family: "modern",
        render_profile: template.normalized_layout_config,
        validated_at: Time.zone.local(2026, 3, 20, 18, 0)
      )
      archived_implementation = create(
        :template_implementation,
        template: template,
        source_artifact: source_artifact,
        status: "archived",
        renderer_family: "modern",
        render_profile: template.normalized_layout_config,
        metadata: {
          "archived_at" => Time.zone.local(2026, 3, 21, 19, 0).iso8601,
          "archived_from_status" => "stable"
        },
        validated_at: Time.zone.local(2026, 3, 19, 18, 0),
        seeded_at: Time.zone.local(2026, 3, 20, 18, 0)
      )
      draft_candidate = create(
        :template_implementation,
        template: template,
        source_artifact: source_artifact,
        status: "draft",
        renderer_family: "modern",
        render_profile: template.normalized_layout_config,
        notes: "Draft candidate"
      )
      create(
        :template_validation_run,
        template: template,
        template_implementation: implementation,
        reference_artifact: source_artifact,
        validation_type: "manual_review",
        status: "passed"
      )
      candidate_validation_run = create(
        :template_validation_run,
        template: template,
        template_implementation: draft_candidate,
        reference_artifact: source_artifact,
        validation_type: "manual_review",
        status: "passed"
      )

      package = described_class.new(template: template).call

      expect(package.dig(:template, :slug)).to eq("modern")
      expect(package.dig(:implementation, :identifier)).to eq(implementation.identifier)
      expect(package.dig(:implementation, :next_promotion_target)).to eq("seeded")
      expect(package.dig(:implementation, :promotion_ready)).to eq(true)
      expect(package[:seed_baseline]).to include(
        available: false,
        ready: false,
        missing_artifact: false,
        implementation_identifier: nil,
        artifact_identifier: nil
      )
      expect(package[:candidate_implementations].size).to eq(1)
      expect(package[:candidate_implementations].first[:identifier]).to eq(draft_candidate.identifier)
      expect(package[:candidate_implementations].first[:promotion_ready]).to eq(true)
      expect(package[:candidate_implementations].first[:next_promotion_target]).to eq("validated")
      expect(package[:candidate_implementations].first.dig(:latest_validation_run, :identifier)).to eq(candidate_validation_run.identifier)
      expect(package[:historical_implementations].size).to eq(2)
      expect(package[:historical_implementations].map { |item| item[:identifier] }).to include(historical_implementation.identifier, archived_implementation.identifier)
      expect(package[:historical_implementations].find { |item| item[:identifier] == historical_implementation.identifier }).to include(
        status: "validated",
        archivable: true,
        next_promotion_target: "stable"
      )
      expect(package[:historical_implementations].find { |item| item[:identifier] == archived_implementation.identifier }).to include(
        status: "archived",
        archivable: false,
        archived_from_status: "stable"
      )
      expect(package[:historical_implementations].find { |item| item[:identifier] == archived_implementation.identifier }[:archived_at]).to eq(Time.zone.local(2026, 3, 21, 19, 0))
      expect(package[:source_artifacts].size).to eq(1)
      expect(package[:derived_artifacts].size).to eq(1)
      expect(package[:documentation_artifacts].size).to eq(1)
      expect(package[:validation_artifacts].size).to eq(1)
      expect(package[:validation_runs].size).to eq(2)
      expect(package[:validation_runs].map { |run| run[:template_implementation_identifier] }).to include(implementation.identifier, draft_candidate.identifier)
      expect(package[:source_artifacts].first[:source_url]).to eq("https://behance.net/example")
    end

    it "includes the ready seed baseline payload for a seeded implementation with a matching seed snapshot" do
      template = create(:template, slug: "modern")
      source_artifact = create(:template_artifact, template: template, artifact_type: "reference_design", lineage_kind: "source", name: "Behance capture")
      implementation = create(
        :template_implementation,
        template: template,
        source_artifact: source_artifact,
        status: "seeded",
        renderer_family: template.layout_family,
        render_profile: template.normalized_layout_config,
        validated_at: Time.zone.local(2026, 3, 21, 18, 0),
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

      package = described_class.new(template: template).call

      expect(package[:seed_baseline]).to include(
        available: true,
        ready: true,
        missing_artifact: false,
        implementation_identifier: implementation.identifier,
        artifact_identifier: seed_artifact.identifier,
        source_artifact_identifier: source_artifact.identifier,
        seeded_at: Time.zone.local(2026, 3, 21, 19, 0)
      )
    end
  end
end
