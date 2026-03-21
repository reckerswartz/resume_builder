require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the Admin::TemplatesHelper. For example:
#
# describe Admin::TemplatesHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe Admin::TemplatesHelper, type: :helper do
  describe '#template_artifact_review_detail' do
    it 'summarizes source coverage, implementation state, and validation run count' do
      template = create(:template, slug: 'editorial-split')
      source_artifact = create(
        :template_artifact,
        template: template,
        artifact_type: 'reference_design',
        lineage_kind: 'source',
        name: 'Behance capture'
      )
      implementation = create(
        :template_implementation,
        template: template,
        source_artifact: source_artifact,
        status: 'stable',
        renderer_family: 'editorial-split',
        render_profile: template.normalized_layout_config
      )
      create(
        :template_validation_run,
        template: template,
        template_implementation: implementation,
        reference_artifact: source_artifact,
        status: 'passed',
        validation_type: 'manual_review'
      )

      expect(helper.template_artifact_review_detail(template)).to include('1 source')
      expect(helper.template_artifact_review_detail(template)).to include('Implementation Stable')
      expect(helper.template_artifact_review_detail(template)).to include('1 validation run')
      expect(helper.template_artifact_review_tone(template)).to eq(:success)
    end
  end

  describe '#template_artifact_review_groups' do
    it 'returns localized artifact groups with source artifacts first' do
      template = create(:template, slug: 'editorial-split')
      create(:template_artifact, template: template, artifact_type: 'reference_design', lineage_kind: 'source', name: 'Behance capture')
      create(:template_artifact, template: template, artifact_type: 'design_note', lineage_kind: 'documentation', name: 'Capture notes')

      groups = helper.template_artifact_review_groups(template)

      expect(groups.first.fetch(:key)).to eq(:source_artifacts)
      expect(groups.first.fetch(:title)).to eq('Source artifacts')
      expect(groups.first.fetch(:artifacts).size).to eq(1)
      expect(groups.second.fetch(:key)).to eq(:documentation_artifacts)
      expect(groups.second.fetch(:artifacts).size).to eq(1)
    end
  end

  describe '#template_artifact_review_title' do
    it 'surfaces draft candidate progress when source artifacts exist but no render-ready implementation is present' do
      template = create(:template, slug: 'editorial-split')
      source_artifact = create(:template_artifact, template: template, artifact_type: 'reference_design', lineage_kind: 'source', name: 'Behance capture')
      create(
        :template_implementation,
        template: template,
        source_artifact: source_artifact,
        status: 'draft',
        renderer_family: template.layout_family,
        render_profile: template.render_layout_config
      )

      expect(helper.template_artifact_review_title(template)).to eq('1 draft candidate in progress')
      expect(helper.template_artifact_review_implementation_badge_label(template)).to eq('1 draft candidate')
      expect(helper.template_artifact_review_implementation_badge_tone(template)).to eq(:info)
    end

    it 'surfaces the seed baseline state when a seeded implementation has a matching seed snapshot' do
      template = create(:template, slug: 'editorial-split')
      source_artifact = create(:template_artifact, template: template, artifact_type: 'reference_design', lineage_kind: 'source', name: 'Behance capture')
      implementation = create(
        :template_implementation,
        template: template,
        source_artifact: source_artifact,
        status: 'seeded',
        renderer_family: template.layout_family,
        render_profile: template.render_layout_config,
        validated_at: Time.zone.local(2026, 3, 21, 18, 15),
        seeded_at: Time.zone.local(2026, 3, 21, 19, 0)
      )
      create(
        :template_artifact,
        template: template,
        artifact_type: 'seed_snapshot',
        lineage_kind: 'derived',
        parent_artifact: source_artifact,
        name: implementation.name,
        version_label: "#{implementation.identifier}-seeded",
        metadata: {
          'artifact_role' => 'seeded_implementation_snapshot',
          'template_implementation_identifier' => implementation.identifier,
          'source_artifact_identifier' => source_artifact.identifier
        }
      )

      expect(helper.template_artifact_review_title(template)).to eq('Seed baseline ready')
      expect(helper.template_seed_baseline_status_label(template)).to eq('Seed baseline ready')
      expect(helper.template_seed_baseline_detail(template)).to include('matching seed snapshot ready')
      expect(helper.template_seed_baseline_tone(template)).to eq(:success)
      expect(helper.template_artifact_review_tone(template)).to eq(:success)
    end
  end

  describe '#template_seed_baseline_status_label' do
    it 'reports missing snapshot follow-up for a seeded implementation without a matching seed snapshot' do
      template = create(:template, slug: 'editorial-split')
      source_artifact = create(:template_artifact, template: template, artifact_type: 'reference_design', lineage_kind: 'source', name: 'Behance capture')
      create(
        :template_implementation,
        template: template,
        source_artifact: source_artifact,
        status: 'seeded',
        renderer_family: template.layout_family,
        render_profile: template.render_layout_config,
        validated_at: Time.zone.local(2026, 3, 21, 18, 15),
        seeded_at: Time.zone.local(2026, 3, 21, 19, 0)
      )

      expect(helper.template_artifact_review_title(template)).to eq('Seed snapshot follow-up needed')
      expect(helper.template_seed_baseline_status_label(template)).to eq('Seed snapshot missing')
      expect(helper.template_seed_baseline_detail(template)).to include('no active seed snapshot matches it yet')
      expect(helper.template_seed_baseline_tone(template)).to eq(:warning)
      expect(helper.template_artifact_review_tone(template)).to eq(:warning)
    end
  end

  describe '#template_candidate_summary' do
    it 'formats the linked source artifact identifier and created timestamp' do
      timestamp = Time.zone.local(2026, 3, 21, 12, 30)

      summary = helper.template_candidate_summary(
        source_artifact_identifier: 'editorial-split-reference-design-behance-capture',
        created_at: timestamp
      )

      expect(summary).to include('Source artifact: editorial-split-reference-design-behance-capture')
      expect(summary).to include(I18n.l(timestamp, format: :long))
    end
  end

  describe '#template_implementation_history_summary' do
    it 'formats the linked source artifact identifier and created timestamp for history rows' do
      timestamp = Time.zone.local(2026, 3, 21, 12, 30)

      summary = helper.template_implementation_history_summary(
        source_artifact_identifier: 'editorial-split-reference-design-behance-capture',
        created_at: timestamp
      )

      expect(summary).to include('Source artifact: editorial-split-reference-design-behance-capture')
      expect(summary).to include(I18n.l(timestamp, format: :long))
    end
  end

  describe '#template_candidate_latest_validation_label' do
    it 'formats the latest validation state for a draft candidate and marks it promotion-ready when passed' do
      timestamp = Time.zone.local(2026, 3, 21, 14, 45)
      candidate = {
        promotion_ready: true,
        latest_validation_run: {
          validation_type: 'manual_review',
          status: 'passed',
          validated_at: timestamp
        }
      }

      expect(helper.template_candidate_latest_validation_label(candidate)).to eq("Manual Review · Passed · #{I18n.l(timestamp, format: :long)}")
      expect(helper.template_candidate_latest_validation_tone(candidate)).to eq(:success)
      expect(helper.template_candidate_promotion_message(candidate)).to include('passed review is recorded')
    end
  end

  describe '#template_implementation_promotion_message' do
    it 'describes the next lifecycle step for a validated implementation' do
      implementation = { status: 'validated', next_promotion_target: 'stable' }

      expect(helper.template_implementation_promotion_message(implementation)).to include('promoted to stable')
      expect(helper.template_implementation_promotion_action_label(implementation)).to eq('Promote to stable')
      expect(helper.template_implementation_promotion_tone(implementation)).to eq(:info)
    end

    it 'describes a seeded implementation as complete' do
      implementation = { status: 'seeded', next_promotion_target: nil }

      expect(helper.template_implementation_promotion_message(implementation)).to include('already been seeded')
      expect(helper.template_implementation_promotion_action_label(implementation)).to be_nil
      expect(helper.template_implementation_promotion_tone(implementation)).to eq(:success)
    end
  end

  describe '#template_implementation_history_message' do
    it 'describes a superseded render-ready implementation as archiveable' do
      implementation = { status: 'validated', archivable: true }

      expect(helper.template_implementation_history_message(implementation)).to include('can be archived')
      expect(helper.template_implementation_archive_action_label(implementation)).to eq('Archive implementation')
      expect(helper.template_implementation_history_tone(implementation)).to eq(:info)
    end

    it 'describes an archived implementation as historical reference' do
      implementation = { status: 'archived', archived_from_status: 'stable', archivable: false }

      expect(helper.template_implementation_history_message(implementation)).to include('after its Stable lifecycle stage')
      expect(helper.template_implementation_archive_action_label(implementation)).to be_nil
      expect(helper.template_implementation_archived_from_badge_label(implementation)).to eq('Archived from Stable')
      expect(helper.template_implementation_history_tone(implementation)).to eq(:neutral)
    end
  end

  describe '#template_validation_run_metric_summary' do
    it 'formats the stored metric summary for admin review' do
      summary = helper.template_validation_run_metric_summary(
        metrics: {
          'pixel_status' => 'close',
          'open_discrepancy_count' => 2,
          'resolved_discrepancy_count' => 1
        }
      )

      expect(summary).to include('Pixel Close')
      expect(summary).to include('2 open discrepancies')
      expect(summary).to include('1 resolved discrepancy')
    end

    it 'falls back to notes when no structured metrics are present' do
      summary = helper.template_validation_run_metric_summary(notes: 'Manual review recorded as passed.')

      expect(summary).to eq('Manual review recorded as passed.')
    end
  end

  describe '#template_headshot_metadata_label' do
    it 'returns Supported when the headshot flag is on' do
      template = build_stubbed(:template, layout_config: ResumeTemplates::Catalog.default_layout_config.merge('supports_headshot' => true))

      expect(helper.template_headshot_metadata_label(template)).to eq('Supported')
    end

    it 'returns Fallback only when the headshot flag is off' do
      template = build_stubbed(:template)

      expect(helper.template_headshot_metadata_label(template)).to eq('Fallback only')
    end
  end

  describe '#template_headshot_metadata_description' do
    it 'explains enabled headshot metadata as renderer support' do
      template = build_stubbed(:template, layout_config: ResumeTemplates::Catalog.default_layout_config.merge('supports_headshot' => true))

      expect(helper.template_headshot_metadata_description(template)).to include('uploaded resume headshot')
      expect(helper.template_headshot_metadata_description(template)).to include('live preview and PDF export')
    end

    it 'explains disabled headshot metadata as fallback-only behavior' do
      template = build_stubbed(:template)

      expect(helper.template_headshot_metadata_description(template)).to include('non-photo identity treatment')
      expect(helper.template_headshot_metadata_description(template)).to include('headshot attached')
    end
  end

  describe '#template_headshot_metadata_tone' do
    it 'uses an informational tone when the internal headshot flag is on' do
      template = build_stubbed(:template, layout_config: ResumeTemplates::Catalog.default_layout_config.merge('supports_headshot' => true))

      expect(helper.template_headshot_metadata_tone(template)).to eq(:info)
    end

    it 'uses a neutral tone when the internal headshot flag is off' do
      template = build_stubbed(:template)

      expect(helper.template_headshot_metadata_tone(template)).to eq(:neutral)
    end
  end
end
