module Admin::SettingsHelper
  def feature_flags_for_settings(platform_setting)
    [
      {
        key: "llm_access",
        label: settings_copy("feature_flags.llm_access.label"),
        description: settings_copy("feature_flags.llm_access.description"),
        enabled: platform_setting.feature_enabled?("llm_access")
      },
      {
        key: "resume_suggestions",
        label: settings_copy("feature_flags.resume_suggestions.label"),
        description: settings_copy("feature_flags.resume_suggestions.description"),
        enabled: platform_setting.feature_enabled?("resume_suggestions")
      },
      {
        key: "autofill_content",
        label: settings_copy("feature_flags.autofill_content.label"),
        description: settings_copy("feature_flags.autofill_content.description"),
        enabled: platform_setting.feature_enabled?("autofill_content")
      },
      {
        key: "photo_processing",
        label: settings_copy("feature_flags.photo_processing.label"),
        description: settings_copy("feature_flags.photo_processing.description"),
        enabled: platform_setting.feature_enabled?("photo_processing")
      },
      {
        key: "resume_image_generation",
        label: settings_copy("feature_flags.resume_image_generation.label"),
        description: settings_copy("feature_flags.resume_image_generation.description"),
        enabled: platform_setting.feature_enabled?("resume_image_generation")
      }
    ]
  end

  def cloud_import_provider_states_for_settings
    Resumes::CloudImportProviderCatalog.all.map do |provider|
      configured = provider.fetch(:configured)

      {
        key: provider.fetch(:key),
        label: provider.fetch(:label),
        description: provider.fetch(:description),
        required_env_vars: provider.fetch(:required_env_vars),
        configured: configured,
        status_label: configured ? settings_copy("cloud_import_provider_states.status.configured") : settings_copy("cloud_import_provider_states.status.setup_required"),
        status_tone: configured ? :success : :warning,
        message: if configured
          I18n.t("resumes.cloud_import_provider_catalog.feedback.configured", provider: provider.fetch(:label))
                 else
          I18n.t("resumes.cloud_import_provider_catalog.feedback.setup_required", provider: provider.fetch(:label), env_vars: provider.fetch(:required_env_vars).to_sentence)
                 end
      }
    end
  end

  def admin_settings_page_state(platform_setting:, llm_models:, text_llm_models:, vision_llm_models:, llm_assignment_model_ids:, llm_providers_count:)
    @admin_settings_page_states ||= Hash.new { |hash, key| hash[key] = {} }
    state_key = [ I18n.locale, llm_models.map(&:id), text_llm_models.map(&:id), vision_llm_models.map(&:id), llm_assignment_model_ids, llm_providers_count ]

    @admin_settings_page_states[platform_setting.object_id][state_key] ||= Admin::SettingsPageState.new(
      platform_setting: platform_setting,
      llm_models: llm_models,
      text_llm_models: text_llm_models,
      vision_llm_models: vision_llm_models,
      llm_assignment_model_ids: llm_assignment_model_ids,
      llm_providers_count: llm_providers_count,
      view_context: self
    )
  end

  def llm_model_options_for_select(llm_models)
    llm_models.map do |llm_model|
      [ [ llm_model.name, settings_llm_model_option_summary(llm_model) ].compact.join(" · "), llm_model.id ]
    end
  end

  def settings_llm_model_option_summary(llm_model)
    [
      llm_model.llm_provider.name,
      llm_model.model_type_label,
      llm_model.parameter_size,
      llm_model.family
    ].compact_blank.join(" · ").presence
  end

  def settings_llm_model_option_meta(llm_model)
    [
      llm_model.parameter_size.presence || llm_model.identifier,
      llm_model.modality_summary.presence
    ].compact_blank.join(" · ").presence
  end

  private
    def settings_copy(key, **options)
      I18n.t("admin.settings_helper.#{key}", **options)
    end
end
