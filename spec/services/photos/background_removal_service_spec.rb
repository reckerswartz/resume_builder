require 'rails_helper'

RSpec.describe Photos::BackgroundRemovalService, type: :service do
  def create_source_photo_asset(photo_profile:, filename: 'source-headshot.png')
    PhotoAsset.new(photo_profile:, asset_kind: :source, status: :ready).tap do |photo_asset|
      photo_asset.file.attach(io: StringIO.new('image-bytes'), filename:, content_type: 'image/png')
      photo_asset.save!
    end
  end

  def tiny_png_base64
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO2Z7mQAAAAASUVORK5CYII='
  end

  let(:user) { create(:user) }
  let(:photo_profile) { PhotoProfile.create!(user:, name: 'Pat Kumar Photo Library', status: :active) }
  let(:source_asset) { create_source_photo_asset(photo_profile:) }

  describe '#call' do
    it 'returns the localized no-models error when no vision generation model is assigned' do
      allow(LlmModelAssignment).to receive(:ready_models_for).with('vision_generation').and_return([])

      result = described_class.new(photo_profile:, source_asset:, user:).call

      expect(result).not_to be_success
      expect(result.asset).to be_nil
      expect(result.error_message).to eq(I18n.t('resumes.photo_library.background_removal_service.no_models'))
    end

    it 'returns the localized no-reusable-image error when no successful provider returns images' do
      allow(LlmModelAssignment).to receive(:ready_models_for).with('vision_generation').and_return([ build_stubbed(:llm_model, :vision_capable) ])
      execution = instance_double('VisionExecution', success?: true, images: [])
      runner = instance_double(Llm::ParallelVisionRunner, call: [ execution ])
      allow(Llm::ParallelVisionRunner).to receive(:new).and_return(runner)

      result = described_class.new(photo_profile:, source_asset:, user:).call

      expect(result).not_to be_success
      expect(result.asset).to be_nil
      expect(result.error_message).to eq(I18n.t('resumes.photo_library.background_removal_service.no_reusable_image'))
    end

    it 'returns the localized no-image-data error when the provider omits image payload data' do
      allow(LlmModelAssignment).to receive(:ready_models_for).with('vision_generation').and_return([ build_stubbed(:llm_model, :vision_capable) ])
      execution = instance_double('VisionExecution', success?: true, images: [ { 'content_type' => 'image/png' } ])
      runner = instance_double(Llm::ParallelVisionRunner, call: [ execution ])
      allow(Llm::ParallelVisionRunner).to receive(:new).and_return(runner)

      result = described_class.new(photo_profile:, source_asset:, user:).call

      expect(result).not_to be_success
      expect(result.asset).to be_nil
      expect(result.error_message).to eq(I18n.t('resumes.photo_library.background_removal_service.no_image_data'))
    end

    it 'persists a cutout asset when a provider returns reusable image data' do
      llm_model = create(:llm_model, :vision_capable)
      allow(LlmModelAssignment).to receive(:ready_models_for).with('vision_generation').and_return([ llm_model ])

      execution = instance_double(
        Llm::ParallelVisionRunner::Execution,
        success?: true,
        images: [
          {
            'base64' => tiny_png_base64,
            'content_type' => 'image/png',
            'filename' => 'background-removed.png'
          }
        ],
        llm_model: llm_model,
        metadata: { 'provider_note' => 'clean-cutout' }
      )
      runner = instance_double(Llm::ParallelVisionRunner, call: [ execution ])
      allow(Llm::ParallelVisionRunner).to receive(:new).and_return(runner)

      source_asset
      result = nil

      expect do
        result = described_class.new(photo_profile:, source_asset:, user:).call
      end.to change(PhotoAsset, :count).by(1)

      expect(result).to be_success
      expect(result.execution).to eq(execution)
      expect(result.error_message).to be_nil
      expect(result.asset).to be_cutout
      expect(result.asset.source_asset).to eq(source_asset)
      expect(result.asset.photo_profile).to eq(photo_profile)
      expect(result.asset.file).to be_attached
      expect(result.asset.metadata['source_asset_id']).to eq(source_asset.id)
      expect(result.asset.metadata['llm_model_id']).to eq(llm_model.id)
      expect(result.asset.metadata['processing_step']).to eq('background_remove')
      expect(result.asset.metadata['background_removed_at']).to be_present
    end
  end
end
