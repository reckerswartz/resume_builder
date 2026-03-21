require 'rails_helper'

RSpec.describe Admin::LlmProviderCatalogSyncService do
  def sync_result(success:, skipped: false, provider:, models: [], created_count: 0, updated_count: 0, deactivated_count: 0, error_message: nil)
    Llm::ProviderModelSyncService::Result.new(
      success: success,
      skipped: skipped,
      provider: provider,
      models: models,
      created_count: created_count,
      updated_count: updated_count,
      deactivated_count: deactivated_count,
      error_message: error_message
    )
  end

  let(:provider) { create(:llm_provider, :nvidia_build) }

  describe '#call' do
    it 'combines the default notice with the sync summary when sync succeeds after save' do
      sync_service = instance_double(
        Llm::ProviderModelSyncService,
        call: sync_result(
          success: true,
          provider: provider,
          models: [ build_stubbed(:llm_model), build_stubbed(:llm_model) ],
          created_count: 1,
          updated_count: 1,
          deactivated_count: 2
        )
      )

      result = described_class.new(
        provider: provider,
        default_notice: 'LLM provider updated.',
        sync_service: sync_service
      ).call

      expect(result).to be_success
      expect(result.provider).to eq(provider)
      expect(result.notice).to eq('LLM provider updated. Synced 2 models. 1 added 1 refreshed 2 deactivated')
      expect(result.alert).to be_nil
    end

    it 'returns only the sync summary for explicit sync requests without a default notice' do
      sync_service = instance_double(
        Llm::ProviderModelSyncService,
        call: sync_result(
          success: true,
          provider: provider,
          models: [ build_stubbed(:llm_model) ],
          created_count: 1,
          updated_count: 0,
          deactivated_count: 0
        )
      )

      result = described_class.new(provider: provider, sync_service: sync_service).call

      expect(result).to be_success
      expect(result.notice).to eq('Synced 1 model. 1 added 0 refreshed')
      expect(result.alert).to be_nil
    end

    it 'surfaces skipped syncs as alerts without a success notice' do
      sync_service = instance_double(
        Llm::ProviderModelSyncService,
        call: sync_result(
          success: false,
          skipped: true,
          provider: provider,
          error_message: 'NVIDIA Build could not resolve NVIDIA_API_KEY.'
        )
      )

      result = described_class.new(provider: provider, default_notice: 'LLM provider created.', sync_service: sync_service).call

      expect(result).to be_skipped
      expect(result.notice).to eq('LLM provider created.')
      expect(result.alert).to eq('Model sync skipped: NVIDIA Build could not resolve NVIDIA_API_KEY.')
    end

    it 'surfaces failed syncs as alerts without a success notice' do
      sync_service = instance_double(
        Llm::ProviderModelSyncService,
        call: sync_result(
          success: false,
          skipped: false,
          provider: provider,
          error_message: 'Provider API timed out.'
        )
      )

      result = described_class.new(provider: provider, sync_service: sync_service).call

      expect(result).not_to be_success
      expect(result.notice).to be_nil
      expect(result.alert).to eq('Model sync failed: Provider API timed out.')
    end
  end
end
