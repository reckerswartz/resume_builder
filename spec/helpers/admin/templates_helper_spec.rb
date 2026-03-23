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
  describe '#template_artifact_review_state' do
    it 'returns a presenter with packaged artifact and lifecycle review state' do
      template = create(:template, slug: 'editorial-split')
      create(:template_artifact, template: template, artifact_type: 'reference_design', lineage_kind: 'source', name: 'Behance capture')

      review_state = helper.template_artifact_review_state(template)

      expect(review_state).to be_a(Admin::Templates::ArtifactReviewState)
      expect(review_state.artifact_review_counts).to include(source_artifacts: 1, candidate_implementations: 0)
      expect(review_state.artifact_review_groups.first.fetch(:title)).to eq('Source artifacts')
      expect(review_state.current_implementation).to eq({})
      expect(review_state.seed_baseline).to include(available: false, ready: false, missing_artifact: false)
      expect(review_state.recent_validation_runs).to eq([])
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

  describe '#template_profile_state' do
    it 'returns a presenter with layout, visibility, and headshot state' do
      template = build_stubbed(
        :template,
        active: true,
        layout_config: ResumeTemplates::Catalog.default_layout_config(family: 'editorial-split')
      )

      profile_state = helper.template_profile_state(template)

      expect(profile_state).to be_a(Admin::Templates::ProfileState)
      expect(profile_state.layout_metadata).to include(
        family_label: 'Editorial Split',
        theme_tone_label: 'Lime',
        shell_style_label: 'Flat'
      )
      expect(profile_state.visibility_label).to eq('User-visible')
      expect(profile_state.headshot_metadata_label).to eq('Supported')
    end
  end
end
