class Admin::SettingsController < Admin::BaseController
  before_action :set_platform_setting
  before_action :load_llm_configuration

  def show
    authorize @platform_setting
  end

  def update
    authorize @platform_setting

    result = Admin::SettingsUpdateService.new(
      platform_setting: @platform_setting,
      platform_setting_params: platform_setting_params,
      role_model_ids: llm_role_assignment_params
    ).call

    return redirect_to admin_settings_path, notice: "Settings updated." if result.success?

    @platform_setting = result.platform_setting
    load_llm_configuration
    render :show, status: :unprocessable_entity
  end

  private
    def set_platform_setting
      @platform_setting = PlatformSetting.current
    end

    def load_llm_configuration
      @llm_models = policy_scope(LlmModel).includes(:llm_provider).order(:name, :identifier)
      @text_llm_models = @llm_models.select(&:supports_text?)
      @vision_llm_models = @llm_models.select(&:supports_vision?)
      @llm_assignment_model_ids = LlmModelAssignment.model_ids_by_role
      @llm_providers_count = policy_scope(LlmProvider).count
    end

    def platform_setting_params
      permitted = params.require(:platform_setting).permit(feature_flags: {}, preferences: {})
      permitted[:feature_flags] = permitted[:feature_flags]&.to_h || {}
      permitted[:preferences] = permitted[:preferences]&.to_h || {}
      permitted.to_h
    end

    def llm_role_assignment_params
      permitted = params.fetch(:llm_role_assignments, ActionController::Parameters.new).permit(
        text_generation: [],
        text_verification: [],
        vision_generation: [],
        vision_verification: []
      )

      permitted.to_h.transform_values { |value| Array(value).reject(&:blank?) }
    end
end
