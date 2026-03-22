require 'rails_helper'

RSpec.describe LlmProvider::CredentialManagement do
  describe '#api_key_reference' do
    it 'strips and returns the stored env var value' do
      provider = build(:llm_provider, :nvidia_build, api_key_env_var: '  NVIDIA_API_KEY  ')

      expect(provider.api_key_reference).to eq('NVIDIA_API_KEY')
    end

    it 'returns nil when blank' do
      provider = build(:llm_provider, api_key_env_var: '  ')

      expect(provider.api_key_reference).to be_nil
    end
  end

  describe '#api_key' do
    it 'resolves environment variable references from ENV' do
      provider = build(:llm_provider, :nvidia_build, api_key_env_var: 'NVIDIA_API_KEY')

      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('NVIDIA_API_KEY').and_return('resolved-secret')

      expect(provider.api_key).to eq('resolved-secret')
    end

    it 'returns nil when env var is set but empty' do
      provider = build(:llm_provider, :nvidia_build, api_key_env_var: 'NVIDIA_API_KEY')

      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('NVIDIA_API_KEY').and_return('')

      expect(provider.api_key).to be_nil
    end

    it 'treats non-env-var patterns as direct tokens' do
      provider = build(:llm_provider, :nvidia_build, api_key_env_var: 'nvapi-1234567890abcdef')

      expect(provider.api_key).to eq('nvapi-1234567890abcdef')
    end

    it 'returns nil when reference is blank' do
      provider = build(:llm_provider, api_key_env_var: nil)

      expect(provider.api_key).to be_nil
    end
  end

  describe '#api_key_reference_type' do
    it 'returns env_var for uppercase env var patterns' do
      provider = build(:llm_provider, :nvidia_build, api_key_env_var: 'NVIDIA_API_KEY')

      expect(provider.api_key_reference_type).to eq('env_var')
    end

    it 'returns direct_token for non-env-var patterns' do
      provider = build(:llm_provider, :nvidia_build, api_key_env_var: 'nvapi-abc123')

      expect(provider.api_key_reference_type).to eq('direct_token')
    end

    it 'returns nil when reference is blank' do
      provider = build(:llm_provider, api_key_env_var: nil)

      expect(provider.api_key_reference_type).to be_nil
    end
  end

  describe '#api_key_reference_field_value' do
    it 'returns the reference for env var types' do
      provider = build(:llm_provider, :nvidia_build, api_key_env_var: 'NVIDIA_API_KEY')

      expect(provider.api_key_reference_field_value).to eq('NVIDIA_API_KEY')
    end

    it 'returns nil for direct token types' do
      provider = build(:llm_provider, :nvidia_build, api_key_env_var: 'nvapi-abc123')

      expect(provider.api_key_reference_field_value).to be_nil
    end
  end

  describe '#masked_api_key_reference' do
    it 'shows env var names unmasked' do
      provider = build(:llm_provider, :nvidia_build, api_key_env_var: 'NVIDIA_API_KEY')

      expect(provider.masked_api_key_reference).to eq('NVIDIA_API_KEY')
    end

    it 'fully masks short direct tokens' do
      provider = build(:llm_provider, :nvidia_build, api_key_env_var: 'short-key')

      expect(provider.masked_api_key_reference).to eq('••••••••')
    end

    it 'partially masks longer direct tokens' do
      provider = build(:llm_provider, :nvidia_build, api_key_env_var: 'nvapi-1234567890abcdef')

      expect(provider.masked_api_key_reference).to eq('nvapi-••••cdef')
    end

    it 'returns nil when reference is blank' do
      provider = build(:llm_provider, api_key_env_var: nil)

      expect(provider.masked_api_key_reference).to be_nil
    end
  end
end
