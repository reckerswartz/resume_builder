require 'rails_helper'

RSpec.describe PhotoBackgroundRemovalJob, type: :job do
  include ActiveJob::TestHelper

  let(:user) { create(:user) }
  let(:resume) { create(:resume, user: user) }
  let(:photo_profile) { PhotoProfile.create!(user: user, name: 'Profile', status: :active) }
  let(:source_asset) do
    PhotoAsset.new(photo_profile: photo_profile, asset_kind: :source, status: :ready).tap do |a|
      a.file.attach(io: StringIO.new('png'), filename: 'source.png', content_type: 'image/png')
      a.save!
    end
  end
  let(:processing_run) do
    photo_profile.photo_processing_runs.create!(
      workflow_type: :background_remove, status: :queued,
      resume: resume, input_asset_ids: [ source_asset.id ]
    )
  end

  let(:cutout_asset) do
    PhotoAsset.new(photo_profile: photo_profile, asset_kind: :cutout, status: :ready, source_asset: source_asset).tap do |a|
      a.file.attach(io: StringIO.new('cutout'), filename: 'cutout.png', content_type: 'image/png')
      a.save!
    end
  end

  before { clear_enqueued_jobs }

  describe '#perform' do
    it 'marks the run as succeeded when the service succeeds' do
      execution = double('execution', metadata: { 'model' => 'test' })
      result = double('result', success?: true, asset: cutout_asset, execution: execution)
      allow(Photos::BackgroundRemovalService).to receive(:new).and_return(double(call: result))

      job = described_class.new(processing_run.id, source_asset.id, user.id, resume.id)
      job.enqueue
      job.perform_now

      expect(processing_run.reload).to be_succeeded
      expect(processing_run.output_asset_ids).to eq([ cutout_asset.id ])
      expect(processing_run.next_step_guidance).to be_present
    end

    it 'marks the run as failed and raises when the service fails' do
      result = double('result', success?: false, error_message: 'No model available')
      allow(Photos::BackgroundRemovalService).to receive(:new).and_return(double(call: result))

      job = described_class.new(processing_run.id, source_asset.id, user.id, resume.id)
      job.enqueue

      expect { job.perform_now }.to raise_error(StandardError, /No model available/)
      expect(processing_run.reload).to be_failed
      expect(processing_run.error_summary).to eq('No model available')
    end

    it 'works without a resume_id' do
      execution = double('execution', metadata: {})
      result = double('result', success?: true, asset: cutout_asset, execution: execution)
      allow(Photos::BackgroundRemovalService).to receive(:new).and_return(double(call: result))

      job = described_class.new(processing_run.id, source_asset.id, user.id)
      job.enqueue
      job.perform_now

      expect(processing_run.reload).to be_succeeded
    end
  end
end
