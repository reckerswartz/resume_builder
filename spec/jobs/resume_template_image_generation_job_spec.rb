require 'rails_helper'

RSpec.describe ResumeTemplateImageGenerationJob, type: :job do
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
  let(:generated_asset) do
    PhotoAsset.new(photo_profile: photo_profile, asset_kind: :generated, status: :ready, source_asset: source_asset).tap do |a|
      a.file.attach(io: StringIO.new('generated'), filename: 'generated.png', content_type: 'image/png')
      a.save!
    end
  end
  let(:processing_run) do
    photo_profile.photo_processing_runs.create!(
      workflow_type: :generate_for_template, status: :queued,
      resume: resume, template: resume.template, input_asset_ids: [source_asset.id]
    )
  end

  before { clear_enqueued_jobs }

  describe '#perform' do
    it 'marks the run as succeeded when generation succeeds' do
      result = double('result', success?: true, assets: [generated_asset], prompt_text: 'Generate headshot')
      allow(Photos::GenerationOrchestrator).to receive(:new).and_return(double(call: result))

      job = described_class.new(processing_run.id, source_asset.id, resume.id, user.id)
      job.enqueue
      job.perform_now

      expect(processing_run.reload).to be_succeeded
      expect(processing_run.output_asset_ids).to eq([generated_asset.id])
      expect(processing_run.response_payload).to include('prompt_text' => 'Generate headshot')
      expect(processing_run.next_step_guidance).to be_present
    end

    it 'marks the run as failed and raises when generation fails' do
      result = double('result', success?: false, error_message: 'Generation failed', prompt_text: 'Generate headshot')
      allow(Photos::GenerationOrchestrator).to receive(:new).and_return(double(call: result))

      job = described_class.new(processing_run.id, source_asset.id, resume.id, user.id)
      job.enqueue

      expect { job.perform_now }.to raise_error(StandardError, /Generation failed/)
      expect(processing_run.reload).to be_failed
      expect(processing_run.error_summary).to eq('Generation failed')
      expect(processing_run.response_payload).to include('prompt_text' => 'Generate headshot')
    end
  end
end
