module Admin::SettingsHelper
  def feature_flags_for_settings(platform_setting)
    [
      {
        key: "llm_access",
        label: "LLM access",
        description: "Allow provider-backed model orchestration for suggestion, autofill, and verification flows.",
        enabled: platform_setting.feature_enabled?("llm_access")
      },
      {
        key: "resume_suggestions",
        label: "Resume suggestions",
        description: "Enable text suggestion workflows that rely on configured text generation and verification models.",
        enabled: platform_setting.feature_enabled?("resume_suggestions")
      },
      {
        key: "autofill_content",
        label: "Autofill content",
        description: "Allow structured autofill flows to use configured LLM roles when source content is available.",
        enabled: platform_setting.feature_enabled?("autofill_content")
      },
      {
        key: "photo_processing",
        label: "Photo library",
        description: "Enable the shared photo library, reusable upload pipeline, and headshot selection flows in the resume builder.",
        enabled: platform_setting.feature_enabled?("photo_processing")
      },
      {
        key: "resume_image_generation",
        label: "Resume image generation",
        description: "Allow background removal, template-specific portrait generation, and verification actions when compatible vision roles are assigned.",
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
        status_label: configured ? "Configured" : "Setup required",
        status_tone: configured ? :success : :warning,
        message: if configured
          "Environment credentials are present. OAuth handoff, remote file chooser, and background import still need a dedicated rollout slice."
        else
          "Add #{provider.fetch(:required_env_vars).to_sentence} to prepare this connector for the next rollout slice."
        end
      }
    end
  end

  def llm_model_options_for_select(llm_models)
    llm_models.map do |llm_model|
      [ [ llm_model.name, settings_llm_model_option_summary(llm_model) ].compact.join(" · "), llm_model.id ]
    end
  end

  def selected_llm_model_id(assignments_by_role, role)
    Array(assignments_by_role.fetch(role.to_s, [])).first
  end

  def selected_llm_model_ids(assignments_by_role, role)
    Array(assignments_by_role.fetch(role.to_s, []))
  end

  def settings_primary_llm_model(assignments_by_role, role, llm_models)
    selected_id = selected_llm_model_id(assignments_by_role, role)
    llm_models.find { |llm_model| llm_model.id == selected_id }
  end

  def settings_selected_llm_models(assignments_by_role, role, llm_models)
    selected_ids = selected_llm_model_ids(assignments_by_role, role)
    llm_models.select { |llm_model| selected_ids.include?(llm_model.id) }
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
end
