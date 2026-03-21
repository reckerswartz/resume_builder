require 'rails_helper'

RSpec.describe Photos::VerificationService, type: :service do
  def create_source_photo_asset(photo_profile:, filename: 'source-headshot.png')
    PhotoAsset.new(photo_profile:, asset_kind: :generated, status: :ready).tap do |photo_asset|
      photo_asset.file.attach(io: StringIO.new('image-bytes'), filename:, content_type: 'image/png')
      photo_asset.save!
    end
  end

  let(:user) { create(:user) }
  let(:template) { create(:template) }
  let(:resume) { create(:resume, user:, template:) }
  let(:photo_profile) { PhotoProfile.create!(user:, name: 'Pat Kumar Photo Library', status: :active) }
  let(:source_asset) { create_source_photo_asset(photo_profile:) }

  describe '#call' do
    it 'returns the localized no-models error when no vision verification model is assigned' do
      allow(LlmModelAssignment).to receive(:ready_models_for).with('vision_verification').and_return([])

      result = described_class.new(source_asset:, resume:, user:).call

      expect(result).not_to be_success
      expect(result.execution).to be_nil
      expect(result.error_message).to eq(I18n.t('resumes.photo_library.verification_service.no_models'))
    end

    it 'returns the localized no-feedback error when no provider returns a successful verification response' do
      allow(LlmModelAssignment).to receive(:ready_models_for).with('vision_verification').and_return([ build_stubbed(:llm_model, :vision_capable) ])
      runner = instance_double(Llm::ParallelVisionRunner, call: [])
      allow(Llm::ParallelVisionRunner).to receive(:new).and_return(runner)

      result = described_class.new(source_asset:, resume:, user:).call

      expect(result).not_to be_success
      expect(result.execution).to be_nil
      expect(result.error_message).to eq(I18n.t('resumes.photo_library.verification_service.no_feedback'))
    end

    it 'returns the first successful verification execution when provider feedback is available' do
      llm_model = create(:llm_model, :vision_capable)
      allow(LlmModelAssignment).to receive(:ready_models_for).with('vision_verification').and_return([ llm_model ])

      failed_execution = instance_double(Llm::ParallelVisionRunner::Execution, success?: false)
      successful_execution = instance_double(Llm::ParallelVisionRunner::Execution, success?: true)
      runner = instance_double(Llm::ParallelVisionRunner, call: [ failed_execution, successful_execution ])
      allow(Llm::ParallelVisionRunner).to receive(:new).and_return(runner)

      result = described_class.new(source_asset:, resume:, user:).call

      expect(result).to be_success
      expect(result.error_message).to be_nil
      expect(result.execution).to eq(successful_execution)
    end
  end
end
