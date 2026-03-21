require 'rails_helper'

RSpec.describe PhotoProcessingRun, type: :model do
  let(:user) { create(:user) }
  let(:photo_profile) { PhotoProfile.create!(user: user, name: 'Test Profile', status: :active) }
  let(:photo_asset) do
    PhotoAsset.new(photo_profile: photo_profile, asset_kind: :source, status: :ready).tap do |asset|
      asset.file.attach(io: StringIO.new('png'), filename: 'test.png', content_type: 'image/png')
      asset.save!
    end
  end

  def create_run(workflow_type: :normalize, status: :queued, **attrs)
    photo_profile.photo_processing_runs.create!(
      workflow_type: workflow_type,
      status: status,
      input_asset_ids: [photo_asset.id],
      **attrs
    )
  end

  describe 'validations' do
    it 'requires workflow_type' do
      run = PhotoProcessingRun.new(photo_profile: photo_profile)

      expect(run).not_to be_valid
      expect(run.errors[:workflow_type]).to be_present
    end

    it 'rejects invalid status values via validation' do
      run = PhotoProcessingRun.new(photo_profile: photo_profile, workflow_type: :normalize, status: nil)
      run.valid?
      # status defaults, so force-clear it to test the validation path
      run.status = nil
      expect(run).not_to be_valid
    end
  end

  describe 'enums' do
    it 'supports all workflow_type values' do
      %w[normalize background_remove enhance generate_for_template verify_candidate].each do |wf|
        run = create_run(workflow_type: wf)
        expect(run.workflow_type).to eq(wf)
        run.destroy!
      end
    end

    it 'supports all status values' do
      %w[queued running succeeded failed cancelled].each do |s|
        run = create_run(status: s)
        expect(run.status).to eq(s)
        run.destroy!
      end
    end
  end

  describe '#mark_running!' do
    it 'transitions from queued to running with a started_at timestamp' do
      run = create_run

      run.mark_running!

      expect(run.reload).to be_running
      expect(run.started_at).to be_present
      expect(run.finished_at).to be_nil
    end
  end

  describe '#mark_succeeded!' do
    it 'transitions to succeeded with output and timestamps' do
      run = create_run(status: :running)

      run.mark_succeeded!(
        output_asset_ids: [photo_asset.id],
        next_step_guidance: 'Review the output',
        metadata: { 'model_used' => 'test-model' }
      )

      expect(run.reload).to be_succeeded
      expect(run.output_asset_ids).to eq([photo_asset.id])
      expect(run.next_step_guidance).to eq('Review the output')
      expect(run.metadata).to include('model_used' => 'test-model')
      expect(run.error_summary).to be_nil
      expect(run.finished_at).to be_present
    end
  end

  describe '#mark_failed!' do
    it 'transitions to failed with error summary and timestamps' do
      run = create_run(status: :running)

      run.mark_failed!(error_summary: 'Model timeout')

      expect(run.reload).to be_failed
      expect(run.error_summary).to eq('Model timeout')
      expect(run.finished_at).to be_present
    end
  end

  describe 'payload normalization' do
    it 'deep-stringifies metadata and request/response payloads on save' do
      run = create_run(metadata: { seeded: true }, request_payload: { prompt: 'test' })

      expect(run.metadata.keys).to all(be_a(String))
      expect(run.request_payload.keys).to all(be_a(String))
    end

    it 'normalizes array payloads to arrays' do
      run = create_run(selected_model_ids: [1, 2])

      expect(run.selected_model_ids).to eq([1, 2])
      expect(run.input_asset_ids).to be_an(Array)
    end
  end

  describe 'scopes' do
    it '.recent returns runs in reverse chronological order' do
      old_run = create_run
      old_run.update_column(:created_at, 1.day.ago)
      new_run = create_run

      expect(PhotoProcessingRun.recent.first).to eq(new_run)
    end
  end
end
