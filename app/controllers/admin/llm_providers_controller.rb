class Admin::LlmProvidersController < Admin::BaseController
  PAGE_SIZE = 10

  before_action :set_llm_provider, only: %i[ show edit update destroy sync_models ]

  def index
    @query = params[:query].to_s.strip
    @status_filter = params[:status].presence_in(%w[active inactive]).to_s
    @adapter_filter = params[:adapter].presence_in(LlmProvider.adapters.keys).to_s
    @sort = LlmProvider.admin_sort_column(params[:sort])
    @direction = table_direction(default: "asc")

    scope = policy_scope(LlmProvider).matching_query(@query).with_active_filter(@status_filter).with_adapter_filter(@adapter_filter)
    @total_count = scope.count
    @total_pages = table_total_pages(total_count: @total_count, per_page: PAGE_SIZE)
    @current_page = table_current_page(total_pages: @total_pages)
    @llm_providers = scope.sorted_for_admin(@sort, @direction).offset((@current_page - 1) * PAGE_SIZE).limit(PAGE_SIZE)
  end

  def show
    authorize @llm_provider
  end

  def new
    @llm_provider = LlmProvider.new(active: true, adapter: :ollama, settings: { "request_timeout_seconds" => 30 })
    authorize @llm_provider
  end

  def edit
    authorize @llm_provider
  end

  def create
    @llm_provider = LlmProvider.new(llm_provider_params)
    authorize @llm_provider

    if @llm_provider.save
      redirect_with_sync_result(@llm_provider, default_notice: "LLM provider created.")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @llm_provider

    if @llm_provider.update(llm_provider_params)
      redirect_with_sync_result(@llm_provider, default_notice: "LLM provider updated.")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def sync_models
    authorize @llm_provider, :sync_models?

    result = sync_provider_models(@llm_provider)
    redirect_to admin_llm_provider_path(@llm_provider), notice: sync_success_message(result), alert: sync_error_message(result)
  end

  def destroy
    authorize @llm_provider

    @llm_provider.destroy!
    redirect_to admin_llm_providers_path, notice: "LLM provider deleted.", status: :see_other
  end

  private
    def set_llm_provider
      @llm_provider = policy_scope(LlmProvider).find(params[:id])
    end

    def llm_provider_params
      permitted = params.require(:llm_provider).permit(:name, :slug, :adapter, :base_url, :api_key_env_var, :active, :request_timeout_seconds)
      existing_settings = (@llm_provider&.settings || {}).deep_stringify_keys
      api_key_reference = permitted[:api_key_env_var].to_s.strip.presence
      if api_key_reference.blank? && @llm_provider&.api_key_reference_type == "direct_token"
        api_key_reference = @llm_provider.api_key_reference
      end

      {
        name: permitted[:name],
        slug: permitted[:slug],
        adapter: permitted[:adapter],
        base_url: permitted[:base_url],
        api_key_env_var: api_key_reference,
        active: permitted[:active],
        settings: existing_settings.merge(
          "request_timeout_seconds" => permitted[:request_timeout_seconds].presence || 30
        )
      }
    end

    def redirect_with_sync_result(provider, default_notice:)
      result = sync_provider_models(provider)
      redirect_to admin_llm_provider_path(provider), notice: combined_notice(default_notice, result), alert: sync_error_message(result)
    end

    def sync_provider_models(provider)
      Llm::ProviderModelSyncService.new(provider:).call
    end

    def combined_notice(default_notice, result)
      [ default_notice, sync_success_message(result) ].compact.join(" ")
    end

    def sync_success_message(result)
      return unless result.success?

      summary = []
      summary << "Synced #{helpers.pluralize(result.models.size, 'model')}."
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
end
