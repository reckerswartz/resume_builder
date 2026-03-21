class Admin::LlmModelsController < Admin::BaseController
  PAGE_SIZE = 10

  before_action :set_llm_model, only: %i[ show edit update destroy ]
  before_action :load_llm_providers, only: %i[ new edit create update ]

  def index
    @query = params[:query].to_s.strip
    @status_filter = params[:status].presence_in(%w[active inactive]).to_s
    @capability_filter = params[:capability].presence_in(%w[text vision]).to_s
    @sort = LlmModel.admin_sort_column(params[:sort])
    @direction = table_direction(default: "asc")

    scope = policy_scope(LlmModel).includes(:llm_provider, :llm_model_assignments)
      .matching_query(@query)
      .with_active_filter(@status_filter)
      .with_capability_filter(@capability_filter)

    @total_count = scope.count
    @total_pages = table_total_pages(total_count: @total_count, per_page: PAGE_SIZE)
    @current_page = table_current_page(total_pages: @total_pages)
    @llm_models = scope.sorted_for_admin(@sort, @direction).offset((@current_page - 1) * PAGE_SIZE).limit(PAGE_SIZE)
  end

  def show
    authorize @llm_model
  end

  def new
    @llm_model = LlmModel.new(
      active: true,
      supports_text: true,
      supports_vision: false,
      settings: {
        "temperature" => 0.2,
        "max_output_tokens" => 300
      }
    )
    authorize @llm_model
  end

  def edit
    authorize @llm_model
  end

  def create
    @llm_model = LlmModel.new(llm_model_params)
    authorize @llm_model

    if @llm_model.save
      redirect_to admin_llm_model_path(@llm_model), notice: I18n.t("admin.llm_models_controller.model_created")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    authorize @llm_model

    if @llm_model.update(llm_model_params)
      redirect_to admin_llm_model_path(@llm_model), notice: I18n.t("admin.llm_models_controller.model_updated")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @llm_model

    @llm_model.destroy!
    redirect_to admin_llm_models_path, notice: I18n.t("admin.llm_models_controller.model_deleted"), status: :see_other
  end

  private
    def set_llm_model
      @llm_model = policy_scope(LlmModel).includes(:llm_provider, :llm_model_assignments).find(params[:id])
    end

    def load_llm_providers
      @llm_providers = policy_scope(LlmProvider).order(:name)
    end

    def llm_model_params
      permitted = params.require(:llm_model).permit(:llm_provider_id, :name, :identifier, :active, :supports_text, :supports_vision, :temperature, :max_output_tokens)

      {
        llm_provider_id: permitted[:llm_provider_id],
        name: permitted[:name],
        identifier: permitted[:identifier],
        active: permitted[:active],
        supports_text: permitted[:supports_text],
        supports_vision: permitted[:supports_vision],
        settings: {
          "temperature" => permitted[:temperature].presence,
          "max_output_tokens" => permitted[:max_output_tokens].presence
        }.compact
      }
    end
end
