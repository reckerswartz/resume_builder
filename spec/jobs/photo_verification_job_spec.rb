require 'rails_helper'

RSpec.describe PhotoVerificationJob, type: :job do
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
      workflow_type: :verify_candidate, status: :queued,
      resume: resume, input_asset_ids: [source_asset.id]
    )
  end

  before { clear_enqueued_jobs }

  describe '#perform' do
    it 'marks the run as succeeded when verification succeeds' do
      execution = double('execution', response_text: 'Looks good', metadata: { 'score' => 0.9 })
      result = double('result', success?: true, execution: execution)
      allow(Photos::VerificationService).to receive(:new).and_return(double(call: result))

      job = described_class.new(processing_run.id, source_asset.id, resume.id, user.id)
      job.enqueue
      job.perform_now

      expect(processing_run.reload).to be_succeeded
      expect(processing_run.response_payload).to include('verification_feedback' => 'Looks good')
      expect(processing_run.next_step_guidance).to be_present
    end

    it 'marks the run as failed and raises when verification fails' do
      result = double('result', success?: false, error_message: 'Vision model unavailable')
      allow(Photos::VerificationService).to receive(:new).and_return(double(call: result))

      job = described_class.new(processing_run.id, source_asset.id, resume.id, user.id)
      job.enqueue

      expect { job.perform_now }.to raise_error(StandardError, /Vision model unavailable/)
      expect(processing_run.reload).to be_failed
      expect(processing_run.error_summary).to eq('Vision model unavailable')
    end
  end
end
