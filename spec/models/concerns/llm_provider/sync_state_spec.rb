require 'rails_helper'

RSpec.describe LlmProvider::SyncState do
  describe '#syncable?' do
    it 'returns true for ollama providers with a base URL' do
      provider = build(:llm_provider, :ollama)
      expect(provider.syncable?).to eq(true)
    end

    it 'returns false when base_url is blank' do
      provider = build(:llm_provider, :ollama, base_url: '')
      expect(provider.syncable?).to eq(false)
    end

    it 'returns true for nvidia providers with a resolvable API key' do
      provider = build(:llm_provider, :nvidia_build, api_key_env_var: 'nvapi-direct-token')
      expect(provider.syncable?).to eq(true)
    end

    it 'returns false for nvidia providers without a resolvable API key' do
      provider = build(:llm_provider, :nvidia_build, api_key_env_var: 'MISSING_KEY')
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('MISSING_KEY').and_return(nil)
      expect(provider.syncable?).to eq(false)
    end
  end

  describe '#syncability_error' do
    it 'returns nil when syncable' do
      provider = build(:llm_provider, :ollama)
      expect(provider.syncability_error).to be_nil
    end

    it 'returns a localized needs-api-key message for nvidia without a reference' do
      provider = build(:llm_provider, :nvidia_build, api_key_env_var: '')
      expect(provider.syncability_error).to eq("#{provider.name} needs an API key reference or token.")
    end

    it 'returns a localized unresolved-env-var message for nvidia with an unresolved env var' do
      provider = build(:llm_provider, :nvidia_build, api_key_env_var: 'MISSING_NVIDIA_KEY')
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('MISSING_NVIDIA_KEY').and_return(nil)
      expect(provider.syncability_error).to include('could not resolve MISSING_NVIDIA_KEY')
    end

    it 'returns a localized not-ready message for non-nvidia providers without a base URL' do
      provider = build(:llm_provider, :ollama, base_url: '')
      expect(provider.syncability_error).to eq("#{provider.name} is not ready for requests.")
    end
  end

  describe '#configured_for_requests?' do
    it 'returns true for active syncable providers' do
      provider = build(:llm_provider, :ollama, active: true)
      expect(provider.configured_for_requests?).to eq(true)
    end

    it 'returns false for inactive providers' do
      provider = build(:llm_provider, :ollama, active: false)
      expect(provider.configured_for_requests?).to eq(false)
    end
  end

  describe '#sync_status' do
    it 'returns :never_synced when no sync metadata exists' do
      provider = build(:llm_provider, :ollama, settings: {})
      expect(provider.sync_status).to eq(:never_synced)
    end

    it 'returns :synced when last_synced_at is present' do
      provider = build(:llm_provider, :ollama, settings: { "last_synced_at" => "2026-03-22T05:00:00Z" })
      expect(provider.sync_status).to eq(:synced)
    end

    it 'returns :error when last_sync_error is present' do
      provider = build(:llm_provider, :ollama, settings: { "last_synced_at" => "2026-03-22T05:00:00Z", "last_sync_error" => "Connection refused" })
      expect(provider.sync_status).to eq(:error)
    end
  end

  describe '#last_synced_model_count' do
    it 'returns the integer count from settings' do
      provider = build(:llm_provider, :ollama, settings: { "last_synced_model_count" => 42 })
      expect(provider.last_synced_model_count).to eq(42)
    end

    it 'returns nil when the count is absent' do
      provider = build(:llm_provider, :ollama, settings: {})
      expect(provider.last_synced_model_count).to be_nil
    end
  end
end
