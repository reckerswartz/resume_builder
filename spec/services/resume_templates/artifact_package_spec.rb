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
        renderer_family: "modern",
        render_profile: template.normalized_layout_config
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
      expect(package[:candidate_implementations].size).to eq(1)
      expect(package[:candidate_implementations].first[:identifier]).to eq(draft_candidate.identifier)
      expect(package[:candidate_implementations].first[:promotion_ready]).to eq(true)
      expect(package[:candidate_implementations].first.dig(:latest_validation_run, :identifier)).to eq(candidate_validation_run.identifier)
      expect(package[:source_artifacts].size).to eq(1)
      expect(package[:derived_artifacts].size).to eq(1)
      expect(package[:documentation_artifacts].size).to eq(1)
      expect(package[:validation_artifacts].size).to eq(1)
      expect(package[:validation_runs].size).to eq(2)
      expect(package[:validation_runs].map { |run| run[:template_implementation_identifier] }).to include(implementation.identifier, draft_candidate.identifier)
      expect(package[:source_artifacts].first[:source_url]).to eq("https://behance.net/example")
    end
  end
end
