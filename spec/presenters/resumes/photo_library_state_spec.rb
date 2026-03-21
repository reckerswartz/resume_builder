require 'rails_helper'

RSpec.describe Resumes::PhotoLibraryState do
  def create_ready_photo_asset(photo_profile:, filename:, asset_kind: :enhanced, status: :ready, metadata: {})
    PhotoAsset.new(photo_profile:, asset_kind:, status:, metadata: metadata).tap do |photo_asset|
      photo_asset.file.attach(io: StringIO.new('image-bytes'), filename:, content_type: 'image/png')
      photo_asset.save!
    end
  end

  let(:user) { create(:user) }
  let(:template) { create(:template) }
  let(:photo_profile) { PhotoProfile.create!(user:, name: 'Pat Kumar Photo Library', status: :active) }
  let(:resume) { create(:resume, user:, template:, photo_profile:) }
  let(:request) { instance_double('request', fullpath: "/resumes/#{resume.id}/edit?step=personal_details") }
  let(:view_context) { instance_double('view_context') }

  subject(:photo_library_state) { described_class.new(resume:, view_context:) }

  before do
    allow(view_context).to receive(:request).and_return(request)
    allow(view_context).to receive(:url_for).and_return('/rails/active_storage/blobs/photo.png')
    allow(view_context).to receive(:photo_profile_photo_asset_path) do |profile, asset, **_params|
      "/photo_profiles/#{profile.id}/photo_assets/#{asset.id}"
    end
    allow(view_context).to receive(:feature_enabled?).and_return(false)
    allow(view_context).to receive(:feature_enabled?).with('photo_processing').and_return(true)
  end

  describe '#asset_cards' do
    it 'builds localized asset badge labels for the shared photo library' do
      asset = create_ready_photo_asset(
        photo_profile:,
        filename: 'headshot.png',
        metadata: { width: 800, height: 1200 }
      )

      card = photo_library_state.asset_cards.find { |asset_card| asset_card.fetch(:id) == asset.id }

      expect(card.fetch(:badges)).to eq(
        [
          I18n.t('resumes.editor_personal_details_step.photo_library.asset_badges.asset_kind.enhanced'),
          I18n.t('resumes.editor_personal_details_step.photo_library.asset_badges.status.ready'),
          I18n.t('resumes.editor_personal_details_step.photo_library.asset_badges.dimensions', width: 800, height: 1200)
        ]
      )
    end
  end

  describe 'recent processing labels' do
    it 'localizes workflow and status labels for recent photo processing runs' do
      run = PhotoProcessingRun.create!(
        photo_profile:,
        resume:,
        template:,
        workflow_type: :background_remove,
        status: :queued
      )

      expect(photo_library_state.workflow_label(run)).to eq(
        I18n.t('resumes.editor_personal_details_step.photo_library.recent_runs.workflow_types.background_remove')
      )
      expect(photo_library_state.run_status_label(run)).to eq(
        I18n.t('resumes.editor_personal_details_step.photo_library.recent_runs.statuses.queued')
      )
    end

    it 'localizes recent-run guidance labels for successful workflows' do
      run = PhotoProcessingRun.create!(
        photo_profile:,
        resume:,
        template:,
        workflow_type: :background_remove,
        status: :succeeded
      )

      expect(photo_library_state.run_guidance_label(run)).to eq(
        I18n.t('resumes.editor_personal_details_step.photo_library.recent_runs.guidance.background_remove')
      )
    end

    it 'does not expose guidance when a run already has an error summary' do
      run = PhotoProcessingRun.create!(
        photo_profile:,
        resume:,
        template:,
        workflow_type: :verify_candidate,
        status: :failed,
        error_summary: 'Provider response was invalid.',
        next_step_guidance: 'Ignore this fallback guidance.'
      )

      expect(photo_library_state.run_guidance_label(run)).to be_nil
    end

    it 'localizes recent-run guidance labels by workflow type' do
      run = PhotoProcessingRun.create!(
        photo_profile:,
        resume:,
        template:,
        workflow_type: :background_remove,
        status: :succeeded,
        next_step_guidance: 'Legacy background removal guidance'
      )

      expect(photo_library_state.run_guidance_label(run)).to eq(
        I18n.t('resumes.editor_personal_details_step.photo_library.recent_runs.guidance.background_remove')
      )
    end
  end
end
