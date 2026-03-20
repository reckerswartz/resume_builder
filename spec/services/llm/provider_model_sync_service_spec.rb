require 'rails_helper'

RSpec.describe Llm::ProviderModelSyncService do
  describe '#call' do
    it 'syncs provider models, infers capabilities, and deactivates missing synced models' do
      provider = create(:llm_provider, :nvidia_build, api_key_env_var: 'nvapi-1234567890abcdef')
      missing_model = create(
        :llm_model,
        llm_provider: provider,
        identifier: 'legacy/missing-model',
        metadata: { 'catalog_source' => described_class::CATALOG_SOURCE },
        active: true
      )
      returning_model = create(
        :llm_model,
        llm_provider: provider,
        identifier: 'microsoft/phi-4-multimodal-instruct',
        name: 'Old Phi',
        supports_text: true,
        supports_vision: false,
        active: false,
        metadata: {
          'catalog_source' => described_class::CATALOG_SOURCE,
          'sync_status' => 'missing_from_provider'
        }
      )

      remote_models = [
        {
          'id' => 'google/gemma-2-9b-it',
          'owned_by' => 'google',
          'created' => 1_710_000_000,
          'input_modalities' => ['text'],
          'output_modalities' => ['text'],
          'details' => {
            'family' => 'gemma',
            'families' => ['gemma'],
            'parameter_size' => '9B',
            'format' => 'nim'
          }
        },
        {
          'id' => 'google/gemma-2-9b-it',
          'owned_by' => 'google',
          'created' => 1_710_000_000,
          'input_modalities' => ['text'],
          'output_modalities' => ['text'],
          'details' => {
            'family' => 'gemma',
            'families' => ['gemma'],
            'parameter_size' => '9B',
            'format' => 'nim'
          }
        },
        {
          'id' => 'microsoft/phi-4-multimodal-instruct',
          'owned_by' => 'microsoft',
          'created' => '2026-03-19T10:00:00Z',
          'input_modalities' => ['text', 'image'],
          'output_modalities' => ['text'],
          'details' => {
            'family' => 'phi',
            'parameter_size' => '14B'
          }
        }
      ]

      client = instance_double('ProviderClient', fetch_models: remote_models)
      allow(Llm::ClientFactory).to receive(:build).with(provider).and_return(client)

      result = described_class.new(provider: provider).call

      expect(result).to be_success
      expect(result.created_count).to eq(1)
      expect(result.updated_count).to eq(1)
      expect(result.deactivated_count).to eq(1)

      gemma_model = provider.llm_models.find_by!(identifier: 'google/gemma-2-9b-it')
      expect(gemma_model.name).to eq('Gemma 2 9b It')
      expect(gemma_model.supports_text).to eq(true)
      expect(gemma_model.supports_vision).to eq(false)
      expect(gemma_model.model_type).to eq('text')
      expect(gemma_model.family).to eq('gemma')
      expect(gemma_model.parameter_size).to eq('9B')
      expect(gemma_model.owned_by).to eq('google')
      expect(gemma_model.metadata['sync_status']).to eq('available')

      expect(returning_model.reload.active).to eq(true)
      expect(returning_model.name).to eq('Phi 4 Multimodal Instruct')
      expect(returning_model.supports_vision).to eq(true)
      expect(returning_model.model_type).to eq('multimodal')
      expect(returning_model.metadata['sync_status']).to eq('available')

      expect(missing_model.reload.active).to eq(false)
      expect(missing_model.metadata['sync_status']).to eq('missing_from_provider')

      provider.reload
      expect(provider.last_synced_model_count).to eq(2)
      expect(provider.last_sync_error).to be_nil
    end

    it 'skips sync when the provider is not ready' do
      provider = create(:llm_provider, :nvidia_build, api_key_env_var: 'MISSING_NVIDIA_KEY')

      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('MISSING_NVIDIA_KEY').and_return(nil)
      expect(Llm::ClientFactory).not_to receive(:build)

      result = described_class.new(provider: provider).call

      expect(result).not_to be_success
      expect(result).to be_skipped
      expect(result.error_message).to include('could not resolve MISSING_NVIDIA_KEY')
      expect(provider.reload.last_sync_error).to include('could not resolve MISSING_NVIDIA_KEY')
    end
  end
end
