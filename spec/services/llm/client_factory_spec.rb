require 'rails_helper'

RSpec.describe Llm::ClientFactory do
  describe '.build' do
    it 'returns an OllamaClient for an ollama provider' do
      provider = create(:llm_provider, adapter: 'ollama')

      client = described_class.build(provider)

      expect(client).to be_a(Llm::Providers::OllamaClient)
    end

    it 'returns an NvidiaBuildClient for an nvidia_build provider' do
      provider = create(:llm_provider, adapter: 'nvidia_build', api_key_env_var: 'NVIDIA_API_KEY')

      client = described_class.build(provider)

      expect(client).to be_a(Llm::Providers::NvidiaBuildClient)
    end

    it 'raises ArgumentError for an unsupported adapter' do
      provider = build(:llm_provider)
      allow(provider).to receive(:adapter).and_return('unknown_adapter')

      expect { described_class.build(provider) }.to raise_error(ArgumentError, /Unsupported LLM provider adapter/)
    end
  end
end
