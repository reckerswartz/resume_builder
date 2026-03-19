class Admin::SettingsController < Admin::BaseController
  def show
    @platform_setting = PlatformSetting.current
    authorize @platform_setting
  end

  def update
    @platform_setting = PlatformSetting.current
    authorize @platform_setting

    if @platform_setting.update(platform_setting_params)
      redirect_to admin_settings_path, notice: "Settings updated."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private
    def platform_setting_params
      permitted = params.require(:platform_setting).permit(feature_flags: {}, preferences: {})
      permitted[:feature_flags] = permitted[:feature_flags]&.to_h || {}
      permitted[:preferences] = permitted[:preferences]&.to_h || {}
      permitted.to_h
    end
end
