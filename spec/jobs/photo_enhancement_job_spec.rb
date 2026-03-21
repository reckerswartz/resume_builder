require 'rails_helper'

RSpec.describe PhotoEnhancementJob, type: :job do
  include ActiveJob::TestHelper

  let(:user) { create(:user) }
  let(:photo_profile) { PhotoProfile.create!(user: user, name: 'Profile', status: :active) }
  let(:source_asset) do
    PhotoAsset.new(photo_profile: photo_profile, asset_kind: :source, status: :ready).tap do |a|
      a.file.attach(io: StringIO.new('png'), filename: 'source.png', content_type: 'image/png')
      a.save!
    end
  end
  let(:enhanced_asset) do
    PhotoAsset.new(photo_profile: photo_profile, asset_kind: :enhanced, status: :ready, source_asset: source_asset).tap do |a|
      a.file.attach(io: StringIO.new('enhanced'), filename: 'enhanced.png', content_type: 'image/png')
      a.save!
    end
  end
  let(:processing_run) do
    photo_profile.photo_processing_runs.create!(
      workflow_type: :enhance, status: :queued, input_asset_ids: [source_asset.id]
    )
  end

  before { clear_enqueued_jobs }

  describe '#perform' do
    it 'marks the run as succeeded when enhancement succeeds' do
      result = double('result', success?: true, asset: enhanced_asset, metadata: { 'enhanced' => true })
      allow(Photos::EnhancementService).to receive(:new).and_return(double(call: result))

      job = described_class.new(processing_run.id, source_asset.id)
      job.enqueue
      job.perform_now

      expect(processing_run.reload).to be_succeeded
      expect(processing_run.output_asset_ids).to eq([enhanced_asset.id])
      expect(processing_run.next_step_guidance).to be_present
    end

    it 'marks the run as failed and raises when enhancement fails' do
      result = double('result', success?: false, error_message: 'Enhancement failed', metadata: {})
      allow(Photos::EnhancementService).to receive(:new).and_return(double(call: result))

      job = described_class.new(processing_run.id, source_asset.id)
      job.enqueue

      expect { job.perform_now }.to raise_error(StandardError, /Enhancement failed/)
      expect(processing_run.reload).to be_failed
      expect(processing_run.error_summary).to eq('Enhancement failed')
    end
  end
end
