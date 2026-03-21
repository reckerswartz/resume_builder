module Admin
  class LlmProviderCatalogSyncService
    Result = Data.define(:provider, :notice, :alert, :sync_result) do
      def success?
        sync_result.success?
      end

      def skipped?
        sync_result.skipped?
      end
    end

    def initialize(provider:, default_notice: nil, sync_service: nil)
      @provider = provider
      @default_notice = default_notice
      @sync_service = sync_service || Llm::ProviderModelSyncService.new(provider: provider)
    end

    def call
      result = sync_service.call

      Result.new(
        provider: result.provider || provider,
        notice: combined_notice(result),
        alert: sync_error_message(result),
        sync_result: result
      )
    end

    private
      attr_reader :default_notice, :provider, :sync_service

      def combined_notice(result)
        [ default_notice.presence, sync_success_message(result) ].compact.join(" ").presence
      end

      def sync_success_message(result)
        return unless result.success?

        summary = []
        summary << "Synced #{pluralized_model_count(result.models.size)}."
        summary << "#{result.created_count} added"
        summary << "#{result.updated_count} refreshed"
        summary << "#{result.deactivated_count} deactivated" if result.deactivated_count.positive?
        summary.join(" ")
      end

      def sync_error_message(result)
        return if result.success?
        return "Model sync skipped: #{result.error_message}" if result.skipped?

        "Model sync failed: #{result.error_message}"
      end

      def pluralized_model_count(count)
        "#{count} #{count == 1 ? 'model' : 'models'}"
      end
  end
end
