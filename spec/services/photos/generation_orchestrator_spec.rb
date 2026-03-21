require 'rails_helper'

RSpec.describe Photos::GenerationOrchestrator, type: :service do
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
  let(:template) { create(:template) }
  let(:resume) { create(:resume, user:, template:) }
  let(:photo_profile) { PhotoProfile.create!(user:, name: 'Pat Kumar Photo Library', status: :active) }
  let(:source_asset) { create_source_photo_asset(photo_profile:) }

  describe '#call' do
    it 'returns the localized no-models error when no vision generation model is assigned' do
      allow(LlmModelAssignment).to receive(:ready_models_for).with('vision_generation').and_return([])

      result = described_class.new(photo_profile:, source_asset:, resume:, template:, user:).call

      expect(result).not_to be_success
      expect(result.assets).to eq([])
      expect(result.error_message).to eq(I18n.t('resumes.photo_library.generation_orchestrator.no_models'))
    end

    it 'returns the localized no-generated-image error when providers do not return reusable images' do
      allow(LlmModelAssignment).to receive(:ready_models_for).with('vision_generation').and_return([ build_stubbed(:llm_model, :vision_capable) ])
      execution = instance_double('VisionExecution', success?: true, images: [], error_message: nil)
      runner = instance_double(Llm::ParallelVisionRunner, call: [ execution ])
      allow(Llm::ParallelVisionRunner).to receive(:new).and_return(runner)

      result = described_class.new(photo_profile:, source_asset:, resume:, template:, user:).call

      expect(result).not_to be_success
      expect(result.assets).to eq([])
      expect(result.error_message).to eq(I18n.t('resumes.photo_library.generation_orchestrator.no_generated_image'))
    end

    it 'builds a prompt and persists generated assets from successful executions' do
      llm_model = create(:llm_model, :vision_capable)
      allow(LlmModelAssignment).to receive(:ready_models_for).with('vision_generation').and_return([ llm_model ])

      execution = instance_double(
        Llm::ParallelVisionRunner::Execution,
        success?: true,
        images: [
          {
            'base64' => tiny_png_base64,
            'content_type' => 'image/png',
            'filename' => 'generated-headshot.png'
          }
        ],
        error_message: nil,
        llm_model: llm_model
      )
      runner = instance_double(Llm::ParallelVisionRunner, call: [ execution ])
      allow(Llm::ParallelVisionRunner).to receive(:new).and_return(runner)

      expected_prompt = Photos::TemplatePromptBuilder.new(
        resume: resume,
        template: template,
        source_asset: source_asset
      ).call

      result = nil

      expect do
        result = described_class.new(photo_profile:, source_asset:, resume:, template:, user:).call
      end.to change(PhotoAsset, :count).by(1)

      expect(result).to be_success
      expect(result.error_message).to be_nil
      expect(result.executions).to eq([ execution ])
      expect(result.prompt_text).to eq(expected_prompt)
      expect(result.assets.size).to eq(1)

      generated_asset = result.assets.first
      expect(generated_asset).to be_generated
      expect(generated_asset.source_asset).to eq(source_asset)
      expect(generated_asset.photo_profile).to eq(photo_profile)
      expect(generated_asset.file).to be_attached
      expect(generated_asset.metadata['source_asset_id']).to eq(source_asset.id)
      expect(generated_asset.metadata['llm_model_id']).to eq(llm_model.id)
      expect(generated_asset.metadata['processing_step']).to eq('generated')
      expect(generated_asset.metadata['generated_at']).to be_present
    end
  end
end
