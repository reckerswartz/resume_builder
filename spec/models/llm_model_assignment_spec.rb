require 'rails_helper'

RSpec.describe LlmModelAssignment do
  describe '.ready_models_for' do
    it 'returns only models whose providers are configured for requests' do
      ready_provider = create(:llm_provider)
      ready_model = create(:llm_model, llm_provider: ready_provider)
      create(:llm_model_assignment, llm_model: ready_model, role: 'text_generation')

      unconfigured_provider = create(:llm_provider, :nvidia_build, api_key_env_var: 'CASCADE_TEST_MISSING_NVIDIA_KEY')
      unconfigured_model = create(:llm_model, llm_provider: unconfigured_provider)
      create(:llm_model_assignment, llm_model: unconfigured_model, role: 'text_generation')

      expect(described_class.ready_models_for(:text_generation)).to eq([ ready_model ])
    end
  end

  describe '.available_for?' do
    it 'returns false when only unconfigured providers are assigned' do
      provider = create(:llm_provider, :nvidia_build, api_key_env_var: 'CASCADE_TEST_UNCONFIGURED_KEY')
      model = create(:llm_model, llm_provider: provider)
      create(:llm_model_assignment, llm_model: model, role: 'text_generation')

      expect(described_class.available_for?(:text_generation)).to eq(false)
    end
  end
end
