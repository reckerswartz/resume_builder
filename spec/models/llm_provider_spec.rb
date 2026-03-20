require 'rails_helper'

RSpec.describe LlmProvider do
  describe '#api_key' do
    it 'treats non-env references as direct tokens' do
      provider = build(:llm_provider, :nvidia_build, api_key_env_var: 'nvapi-1234567890abcdef')

      expect(provider.api_key).to eq('nvapi-1234567890abcdef')
      expect(provider.api_key_reference_type).to eq('direct_token')
      expect(provider.syncable?).to eq(true)
    end

    it 'resolves environment variable references' do
      provider = build(:llm_provider, :nvidia_build, api_key_env_var: 'NVIDIA_API_KEY')

      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('NVIDIA_API_KEY').and_return('resolved-secret')

      expect(provider.api_key).to eq('resolved-secret')
      expect(provider.api_key_reference_type).to eq('env_var')
    end
  end

  describe '#syncability_error' do
    it 'reports unresolved env var references for NVIDIA providers' do
      provider = build(:llm_provider, :nvidia_build, api_key_env_var: 'MISSING_NVIDIA_KEY')

      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('MISSING_NVIDIA_KEY').and_return(nil)

      expect(provider.syncable?).to eq(false)
      expect(provider.syncability_error).to include('could not resolve MISSING_NVIDIA_KEY')
    end
  end
end
