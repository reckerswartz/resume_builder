require "rails_helper"

RSpec.describe Admin::Templates::ArtifactReviewState do
  describe "artifact review summary state" do
    it "summarizes source coverage, implementation state, and validation run count" do
      template = create(:template, slug: "editorial-split")
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
        status: "stable",
        renderer_family: "editorial-split",
        render_profile: template.normalized_layout_config
      )
      create(
        :template_validation_run,
        template: template,
        template_implementation: implementation,
        reference_artifact: source_artifact,
        status: "passed",
        validation_type: "manual_review"
      )

      review_state = described_class.new(template: template)

      expect(review_state.artifact_review_detail).to include("1 source")
      expect(review_state.artifact_review_detail).to include("Implementation Stable")
      expect(review_state.artifact_review_detail).to include("1 validation run")
      expect(review_state.artifact_review_tone).to eq(:success)
    end

    it "surfaces draft candidate progress when source artifacts exist but no render-ready implementation is present" do
      template = create(:template, slug: "editorial-split")
      source_artifact = create(:template_artifact, template: template, artifact_type: "reference_design", lineage_kind: "source", name: "Behance capture")
      create(
        :template_implementation,
        template: template,
        source_artifact: source_artifact,
        status: "draft",
        renderer_family: template.layout_family,
        render_profile: template.render_layout_config
      )

      review_state = described_class.new(template: template)

      expect(review_state.artifact_review_title).to eq("1 draft candidate in progress")
      expect(review_state.artifact_review_implementation_badge_label).to eq("1 draft candidate")
      expect(review_state.artifact_review_implementation_badge_tone).to eq(:info)
    end
  end

  describe "seed baseline state" do
    it "surfaces the seed baseline state when a seeded implementation has a matching seed snapshot" do
      template = create(:template, slug: "editorial-split")
      source_artifact = create(:template_artifact, template: template, artifact_type: "reference_design", lineage_kind: "source", name: "Behance capture")
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
      create(
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

      review_state = described_class.new(template: template)

      expect(review_state.artifact_review_title).to eq("Seed baseline ready")
      expect(review_state.seed_baseline_status_label).to eq("Seed baseline ready")
      expect(review_state.seed_baseline_detail).to include("matching seed snapshot ready")
      expect(review_state.seed_baseline_tone).to eq(:success)
      expect(review_state.artifact_review_tone).to eq(:success)
    end

    it "reports missing snapshot follow-up for a seeded implementation without a matching seed snapshot" do
      template = create(:template, slug: "editorial-split")
      source_artifact = create(:template_artifact, template: template, artifact_type: "reference_design", lineage_kind: "source", name: "Behance capture")
      create(
        :template_implementation,
        template: template,
        source_artifact: source_artifact,
        status: "seeded",
        renderer_family: template.layout_family,
        render_profile: template.render_layout_config,
        validated_at: Time.zone.local(2026, 3, 21, 18, 15),
        seeded_at: Time.zone.local(2026, 3, 21, 19, 0)
      )

      review_state = described_class.new(template: template)

      expect(review_state.artifact_review_title).to eq("Seed snapshot follow-up needed")
      expect(review_state.seed_baseline_status_label).to eq("Seed snapshot missing")
      expect(review_state.seed_baseline_detail).to include("no active seed snapshot matches it yet")
      expect(review_state.seed_baseline_tone).to eq(:warning)
      expect(review_state.artifact_review_tone).to eq(:warning)
    end
  end

  describe "artifact groups and packaged collections" do
    it "returns localized artifact groups with source artifacts first" do
      template = create(:template, slug: "editorial-split")
      create(:template_artifact, template: template, artifact_type: "reference_design", lineage_kind: "source", name: "Behance capture")
      create(:template_artifact, template: template, artifact_type: "design_note", lineage_kind: "documentation", name: "Capture notes")

      review_state = described_class.new(template: template)
      groups = review_state.artifact_review_groups

      expect(groups.first.fetch(:key)).to eq(:source_artifacts)
      expect(groups.first.fetch(:title)).to eq("Source artifacts")
      expect(groups.first.fetch(:artifacts).size).to eq(1)
      expect(groups.second.fetch(:key)).to eq(:documentation_artifacts)
      expect(groups.second.fetch(:artifacts).size).to eq(1)
      expect(review_state.current_implementation).to eq({})
      expect(review_state.candidate_implementations).to eq([])
      expect(review_state.historical_implementations).to eq([])
      expect(review_state.recent_validation_runs).to eq([])
    end
  end
end
