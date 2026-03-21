require 'rails_helper'
require 'base64'

RSpec.describe PhotoNormalizeJob, type: :job do
  include ActiveJob::TestHelper

  def create_source_photo_asset(photo_profile:, filename: 'source-headshot.png')
    PhotoAsset.new(photo_profile:, asset_kind: :source, status: :uploaded).tap do |photo_asset|
      photo_asset.file.attach(io: StringIO.new(Base64.decode64('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO2Z7mQAAAAASUVORK5CYII=')), filename:, content_type: 'image/png')
      photo_asset.save!
    end
  end

  let(:user) { create(:user) }
  let(:photo_profile) { PhotoProfile.create!(user:, name: 'Pat Kumar Photo Library', status: :active) }

  before do
    clear_enqueued_jobs
  end

  describe '#perform' do
    it 'stores a normalized derivative, updates the processing run, and queues enhancement' do
      source_asset = create_source_photo_asset(photo_profile:)
      processing_run = PhotoProcessingRun.create!(
        photo_profile: photo_profile,
        workflow_type: :normalize,
        status: :queued,
        input_asset_ids: [ source_asset.id ]
      )

      expect do
        described_class.perform_now(processing_run.id, source_asset.id)
      end.to change(JobLog, :count).by(2).and change { photo_profile.photo_assets.where(asset_kind: :normalized).count }.by(1)

      processing_run.reload
      normalized_asset = photo_profile.photo_assets.where(asset_kind: :normalized).order(:created_at).last
      job_log = JobLog.where(job_type: 'PhotoNormalizeJob').order(:created_at).last
      enhancement_run = photo_profile.photo_processing_runs.where(workflow_type: :enhance).order(:created_at).last

      expect(processing_run).to be_succeeded
      expect(processing_run.output_asset_ids).to eq([ normalized_asset.id ])
      expect(normalized_asset).to be_ready
      expect(normalized_asset.file).to be_attached
      expect(source_asset.reload).to be_ready
      expect(job_log).to be_succeeded
      expect(enhancement_run).to be_queued
      expect(job_log.output).to include(
        'photo_processing_run_id' => processing_run.id,
        'source_asset_id' => source_asset.id,
        'output_asset_ids' => [ normalized_asset.id ]
      )
      expect(enqueued_jobs.map { |job| job[:job] }).to include(PhotoEnhancementJob)
    end
  end
end
