require 'rails_helper'

RSpec.describe Photos::ProcessingRunLauncher do
  include ActiveJob::TestHelper

  let(:user) { create(:user) }
  let(:resume) { create(:resume, user: user) }
  let(:photo_profile) { PhotoProfile.create!(user: user, name: 'Test Profile', status: :active) }
  let(:photo_asset) do
    PhotoAsset.new(photo_profile: photo_profile, asset_kind: :source, status: :ready).tap do |asset|
      asset.file.attach(io: StringIO.new('png'), filename: 'test.png', content_type: 'image/png')
      asset.save!
    end
  end

  before { clear_enqueued_jobs }

  def build_launcher(workflow_type:, resume: self.resume)
    described_class.new(
      photo_profile: photo_profile,
      photo_asset: photo_asset,
      user: user,
      workflow_type: workflow_type,
      resume: resume
    )
  end

  describe '#call' do
    context 'background_remove' do
      it 'creates a queued run and enqueues PhotoBackgroundRemovalJob' do
        provider = create(:llm_provider)
        model = create(:llm_model, :vision_capable, llm_provider: provider)
        create(:llm_model_assignment, llm_model: model, role: 'vision_generation')

        result = build_launcher(workflow_type: 'background_remove').call

        expect(result).to be_success
        expect(result.run).to be_a(PhotoProcessingRun)
        expect(result.run.workflow_type).to eq('background_remove')
        expect(result.run).to be_queued
        expect(result.run.resume).to eq(resume)
        expect(result.run.template).to eq(resume.template)
        expect(result.run.input_asset_ids).to eq([photo_asset.id])
        expect(enqueued_jobs.map { |j| j[:job] }).to include(PhotoBackgroundRemovalJob)
      end

      it 'succeeds without a resume context' do
        provider = create(:llm_provider)
        model = create(:llm_model, :vision_capable, llm_provider: provider)
        create(:llm_model_assignment, llm_model: model, role: 'vision_generation')

        result = build_launcher(workflow_type: 'background_remove', resume: nil).call

        expect(result).to be_success
        expect(result.run.resume).to be_nil
      end
    end

    context 'generate_for_template' do
      it 'creates a queued run and enqueues ResumeTemplateImageGenerationJob' do
        provider = create(:llm_provider)
        model = create(:llm_model, :vision_capable, llm_provider: provider)
        create(:llm_model_assignment, llm_model: model, role: 'vision_generation')

        result = build_launcher(workflow_type: 'generate_for_template').call

        expect(result).to be_success
        expect(result.run.workflow_type).to eq('generate_for_template')
        expect(enqueued_jobs.map { |j| j[:job] }).to include(ResumeTemplateImageGenerationJob)
      end

      it 'fails when resume is required but missing' do
        result = build_launcher(workflow_type: 'generate_for_template', resume: nil).call

        expect(result).not_to be_success
        expect(result.error_message).to eq(I18n.t('resumes.photo_library.controller.resume_required'))
        expect(result.run).to be_nil
      end
    end

    context 'verify_candidate' do
      it 'creates a queued run and enqueues PhotoVerificationJob' do
        provider = create(:llm_provider)
        model = create(:llm_model, :vision_capable, llm_provider: provider)
        create(:llm_model_assignment, llm_model: model, role: 'vision_verification')

        result = build_launcher(workflow_type: 'verify_candidate').call

        expect(result).to be_success
        expect(result.run.workflow_type).to eq('verify_candidate')
        expect(enqueued_jobs.map { |j| j[:job] }).to include(PhotoVerificationJob)
      end

      it 'fails when resume is required but missing' do
        result = build_launcher(workflow_type: 'verify_candidate', resume: nil).call

        expect(result).not_to be_success
        expect(result.error_message).to eq(I18n.t('resumes.photo_library.controller.resume_required'))
      end
    end

    context 'unknown workflow' do
      it 'returns an error result' do
        result = build_launcher(workflow_type: 'unknown_workflow').call

        expect(result).not_to be_success
        expect(result.error_message).to include('Unknown workflow type')
      end
    end
  end
end
