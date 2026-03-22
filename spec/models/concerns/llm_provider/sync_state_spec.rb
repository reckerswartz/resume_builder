require 'rails_helper'

RSpec.describe LlmProvider::SyncState do
  describe '#syncable?' do
    it 'returns true for ollama providers with a base URL' do
      provider = build(:llm_provider, adapter: 'ollama', base_url: 'http://localhost:11434')

      expect(provider.syncable?).to eq(true)
    end

    it 'returns false when base URL is blank' do
      provider = build(:llm_provider, adapter: 'ollama', base_url: '')

      expect(provider.syncable?).to eq(false)
    end

    it 'returns true for nvidia providers with a resolved API key' do
      provider = build(:llm_provider, :nvidia_build, api_key_env_var: 'nvapi-direct-token')

      expect(provider.syncable?).to eq(true)
    end

    it 'returns false for nvidia providers without a resolved API key' do
      provider = build(:llm_provider, :nvidia_build, api_key_env_var: 'MISSING_KEY')

      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('MISSING_KEY').and_return(nil)

      expect(provider.syncable?).to eq(false)
    end
  end

  describe '#syncability_error' do
    it 'returns nil when syncable' do
      provider = build(:llm_provider, adapter: 'ollama')

      expect(provider.syncability_error).to be_nil
    end

    it 'returns the localized needs-api-key message for nvidia without a reference' do
      provider = build(:llm_provider, :nvidia_build, api_key_env_var: '')

      expect(provider.syncability_error).to eq(
        I18n.t('llm_provider.syncability_error.needs_api_key', name: provider.name)
      )
    end

    it 'returns the localized unresolved-env-var message for nvidia with missing ENV' do
      provider = build(:llm_provider, :nvidia_build, api_key_env_var: 'MISSING_NVIDIA_KEY')

      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('MISSING_NVIDIA_KEY').and_return(nil)

      expect(provider.syncability_error).to eq(
        I18n.t('llm_provider.syncability_error.unresolved_env_var', name: provider.name, reference: 'MISSING_NVIDIA_KEY')
      )
      expect(provider.syncability_error).to include('could not resolve MISSING_NVIDIA_KEY')
    end

    it 'returns the localized not-ready message for other unsyncable states' do
      provider = build(:llm_provider, adapter: 'ollama', base_url: '')

      expect(provider.syncability_error).to eq(
        I18n.t('llm_provider.syncability_error.not_ready', name: provider.name)
      )
    end
  end

  describe '#configured_for_requests?' do
    it 'returns true when active and syncable' do
      provider = build(:llm_provider, adapter: 'ollama', active: true)

      expect(provider.configured_for_requests?).to eq(true)
    end

    it 'returns false when inactive' do
      provider = build(:llm_provider, adapter: 'ollama', active: false)

      expect(provider.configured_for_requests?).to eq(false)
    end
  end

  describe '#last_synced_at' do
    it 'parses the stored ISO8601 timestamp' do
      provider = build(:llm_provider, settings: { 'last_synced_at' => '2026-03-22T03:00:00Z' })

      expect(provider.last_synced_at).to be_a(Time)
      expect(provider.last_synced_at.iso8601).to eq('2026-03-22T03:00:00Z')
    end

    it 'returns nil when blank' do
      provider = build(:llm_provider, settings: {})

      expect(provider.last_synced_at).to be_nil
    end

    it 'returns nil for unparseable values' do
      provider = build(:llm_provider, settings: { 'last_synced_at' => 'not-a-date' })

      expect(provider.last_synced_at).to be_nil
    end
  end

  describe '#last_synced_model_count' do
    it 'returns the integer count when present' do
      provider = build(:llm_provider, settings: { 'last_synced_model_count' => 42 })

      expect(provider.last_synced_model_count).to eq(42)
    end

    it 'returns nil when absent' do
      provider = build(:llm_provider, settings: {})

      expect(provider.last_synced_model_count).to be_nil
    end
  end

  describe '#last_sync_error' do
    it 'returns the stored error message' do
      provider = build(:llm_provider, settings: { 'last_sync_error' => 'Connection refused' })

      expect(provider.last_sync_error).to eq('Connection refused')
    end

    it 'returns nil when blank' do
      provider = build(:llm_provider, settings: { 'last_sync_error' => '' })

      expect(provider.last_sync_error).to be_nil
    end
  end

  describe '#sync_status' do
    it 'returns :error when a sync error is present' do
      provider = build(:llm_provider, settings: { 'last_sync_error' => 'timeout', 'last_synced_at' => '2026-03-22T03:00:00Z' })

      expect(provider.sync_status).to eq(:error)
    end

    it 'returns :synced when last_synced_at is present and no error' do
      provider = build(:llm_provider, settings: { 'last_synced_at' => '2026-03-22T03:00:00Z' })

      expect(provider.sync_status).to eq(:synced)
    end

    it 'returns :never_synced when no sync metadata exists' do
      provider = build(:llm_provider, settings: {})

      expect(provider.sync_status).to eq(:never_synced)
    end
  end
end
