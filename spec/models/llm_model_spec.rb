require 'rails_helper'

RSpec.describe LlmModel, type: :model do
  let(:provider) { create(:llm_provider) }

  describe 'validations' do
    it 'requires name and identifier' do
      model = LlmModel.new(llm_provider: provider, name: '', identifier: '')
      expect(model).not_to be_valid
      expect(model.errors[:name]).to include("can't be blank")
      expect(model.errors[:identifier]).to include("can't be blank")
    end

    it 'enforces unique identifier per provider' do
      create(:llm_model, llm_provider: provider, identifier: 'llama3:latest')
      duplicate = build(:llm_model, llm_provider: provider, identifier: 'llama3:latest')

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:identifier]).to include('has already been taken')
    end

    it 'allows the same identifier across different providers' do
      other_provider = create(:llm_provider)
      create(:llm_model, llm_provider: provider, identifier: 'shared-model')

      model = build(:llm_model, llm_provider: other_provider, identifier: 'shared-model')
      expect(model).to be_valid
    end
  end

  describe 'normalization' do
    it 'strips name and identifier on save' do
      model = create(:llm_model, llm_provider: provider, name: '  Llama 3  ', identifier: '  llama3:latest  ')

      expect(model.name).to eq('Llama 3')
      expect(model.identifier).to eq('llama3:latest')
    end

    it 'deep-stringifies settings and metadata' do
      model = create(:llm_model, llm_provider: provider, settings: { temperature: 0.5 }, metadata: { seeded: true })

      expect(model.settings.keys).to all(be_a(String))
      expect(model.metadata.keys).to all(be_a(String))
    end
  end

  describe '#supports_role?' do
    it 'returns true for text_generation when supports_text is true' do
      model = build(:llm_model, supports_text: true, supports_vision: false)

      expect(model.supports_role?('text_generation')).to be(true)
      expect(model.supports_role?('text_verification')).to be(true)
    end

    it 'returns true for vision_generation when supports_vision is true' do
      model = build(:llm_model, :vision_capable)

      expect(model.supports_role?('vision_generation')).to be(true)
      expect(model.supports_role?('vision_verification')).to be(true)
    end

    it 'returns false for vision roles when only text is supported' do
      model = build(:llm_model, supports_text: true, supports_vision: false)

      expect(model.supports_role?('vision_generation')).to be(false)
    end

    it 'returns false for unknown roles' do
      model = build(:llm_model, supports_text: true, supports_vision: true)

      expect(model.supports_role?('unknown_role')).to be(false)
    end
  end

  describe '#model_type' do
    it 'returns multimodal when both text and vision are supported' do
      model = build(:llm_model, supports_text: true, supports_vision: true)

      expect(model.model_type).to eq('multimodal')
    end

    it 'returns text when only text is supported' do
      model = build(:llm_model, supports_text: true, supports_vision: false)

      expect(model.model_type).to eq('text')
    end

    it 'returns vision when only vision is supported' do
      model = build(:llm_model, supports_text: false, supports_vision: true)

      expect(model.model_type).to eq('vision')
    end

    it 'prefers metadata model_type over inferred' do
      model = build(:llm_model, supports_text: true, supports_vision: true, metadata: { 'model_type' => 'chat' })

      expect(model.model_type).to eq('chat')
    end
  end

  describe '#temperature and #max_output_tokens' do
    it 'returns settings values when present' do
      model = build(:llm_model, settings: { 'temperature' => 0.7, 'max_output_tokens' => 500 })

      expect(model.temperature).to eq(0.7)
      expect(model.max_output_tokens).to eq(500)
    end

    it 'returns nil when settings are blank' do
      model = build(:llm_model, settings: {})

      expect(model.temperature).to be_nil
      expect(model.max_output_tokens).to be_nil
    end
  end

  describe 'scopes' do
    it '.active returns only active models' do
      active = create(:llm_model, llm_provider: provider, active: true)
      create(:llm_model, llm_provider: provider, active: false)

      expect(LlmModel.active).to contain_exactly(active)
    end

    it '.text_capable returns models with text support' do
      text_model = create(:llm_model, llm_provider: provider, supports_text: true)
      create(:llm_model, llm_provider: provider, supports_text: false)

      expect(LlmModel.text_capable).to contain_exactly(text_model)
    end

    it '.vision_capable returns models with vision support' do
      vision_model = create(:llm_model, :vision_capable, llm_provider: provider)
      create(:llm_model, llm_provider: provider, supports_vision: false)

      expect(LlmModel.vision_capable).to contain_exactly(vision_model)
    end

    it '.matching_query searches by model name, identifier, and provider name' do
      matching = create(:llm_model, llm_provider: provider, name: 'Llama 3.2', identifier: 'llama3.2:latest')
      create(:llm_model, llm_provider: provider, name: 'Gemma', identifier: 'gemma:latest')

      expect(LlmModel.matching_query('llama')).to contain_exactly(matching)
    end

    it '.with_active_filter filters by active status string' do
      active = create(:llm_model, llm_provider: provider, active: true)
      inactive = create(:llm_model, llm_provider: provider, active: false)

      expect(LlmModel.with_active_filter('active')).to contain_exactly(active)
      expect(LlmModel.with_active_filter('inactive')).to contain_exactly(inactive)
      expect(LlmModel.with_active_filter('')).to contain_exactly(active, inactive)
    end

    it '.with_capability_filter filters by text or vision' do
      text_only = create(:llm_model, llm_provider: provider, supports_text: true, supports_vision: false)
      vision_only = create(:llm_model, llm_provider: provider, supports_text: false, supports_vision: true)

      expect(LlmModel.with_capability_filter('text')).to contain_exactly(text_only)
      expect(LlmModel.with_capability_filter('vision')).to contain_exactly(vision_only)
    end
  end

  describe '.admin_sort_column' do
    it 'returns the column when valid' do
      expect(LlmModel.admin_sort_column('provider')).to eq('provider')
    end

    it 'falls back to name for invalid columns' do
      expect(LlmModel.admin_sort_column('bogus')).to eq('name')
    end
  end
end
