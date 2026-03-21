module Admin
  class SettingsPageState
    HUB_SECTION_KEYS = {
      "feature-access" => "feature_access",
      "platform-defaults" => "platform_defaults",
      "cloud-import-connectors" => "cloud_import_connectors",
      "llm-orchestration" => "llm_orchestration"
    }.freeze

    attr_reader :llm_models, :llm_providers_count, :text_llm_models, :vision_llm_models

    def initialize(platform_setting:, llm_models:, text_llm_models:, vision_llm_models:, llm_assignment_model_ids:, llm_providers_count:, view_context:)
      @platform_setting = platform_setting
      @llm_models = llm_models
      @text_llm_models = text_llm_models
      @vision_llm_models = vision_llm_models
      @llm_assignment_model_ids = llm_assignment_model_ids
      @llm_providers_count = llm_providers_count
      @view_context = view_context
    end

    def page_header_attributes
      {
        eyebrow: copy("page_header.eyebrow"),
        title: copy("page_header.title"),
        description: copy("page_header.description"),
        badges: [
          { label: copy("page_header.badges.enabled", enabled: enabled_feature_count, total: feature_flags.size), tone: :neutral },
          { label: copy("page_header.badges.providers", count: llm_providers_count), tone: :neutral },
          { label: copy("page_header.badges.models", count: llm_models.count), tone: :neutral }
        ],
        actions: [
          { label: copy("page_header.actions.manage_templates"), path: view_context.admin_templates_path, style: :secondary },
          { label: copy("page_header.actions.manage_providers"), path: view_context.admin_llm_providers_path, style: :secondary },
          { label: copy("page_header.actions.manage_models"), path: view_context.admin_llm_models_path, style: :primary }
        ],
        density: :compact
      }
    end

    def feature_flags
      @feature_flags ||= view_context.feature_flags_for_settings(platform_setting)
    end

    def enabled_feature_count
      @enabled_feature_count ||= feature_flags.count { |flag| flag.fetch(:enabled) }
    end

    def default_template_slug
      platform_setting.preferences.fetch("default_template_slug", "modern")
    end

    def support_email
      platform_setting.preferences.fetch("support_email", "support@example.com")
    end

    def text_primary_model
      @text_primary_model ||= primary_llm_model_for(:text_generation, text_llm_models)
    end

    def text_verification_models
      @text_verification_models ||= selected_llm_models_for(:text_verification, text_llm_models)
    end

    def text_generation_model_id
      @text_generation_model_id ||= selected_llm_model_id_for(:text_generation)
    end

    def text_verification_model_ids
      @text_verification_model_ids ||= selected_llm_model_ids_for(:text_verification)
    end

    def vision_primary_model
      @vision_primary_model ||= primary_llm_model_for(:vision_generation, vision_llm_models)
    end

    def vision_verification_models
      @vision_verification_models ||= selected_llm_models_for(:vision_verification, vision_llm_models)
    end

    def vision_generation_model_id
      @vision_generation_model_id ||= selected_llm_model_id_for(:vision_generation)
    end

    def vision_verification_model_ids
      @vision_verification_model_ids ||= selected_llm_model_ids_for(:vision_verification)
    end

    def cloud_import_provider_states
      @cloud_import_provider_states ||= view_context.cloud_import_provider_states_for_settings
    end

    def configured_cloud_import_provider_count
      @configured_cloud_import_provider_count ||= cloud_import_provider_states.count { |provider| provider.fetch(:configured) }
    end

    def hub_sections
      HUB_SECTION_KEYS.map do |id, key|
        {
          id: id,
          label: copy("hub_sections.#{key}.label"),
          caption: copy("hub_sections.#{key}.caption")
        }
      end
    end

    def workflow_ready_count
      @workflow_ready_count ||= [ text_primary_model.present?, vision_primary_model.present? ].count(true)
    end

    def save_posture_ready?
      workflow_ready_count == 2 && configured_cloud_import_provider_count == cloud_import_provider_states.size
    end

    private
      attr_reader :llm_assignment_model_ids, :platform_setting, :view_context

      def copy(key, **options)
        I18n.t("admin.settings_page_state.#{key}", **options)
      end

      def primary_llm_model_for(role, llm_models)
        selected_id = selected_llm_model_id_for(role)
        llm_models.find { |llm_model| llm_model.id == selected_id }
      end

      def selected_llm_model_id_for(role)
        selected_llm_model_ids_for(role).first
      end

      def selected_llm_model_ids_for(role)
        Array(llm_assignment_model_ids.fetch(role.to_s, []))
      end

      def selected_llm_models_for(role, llm_models)
        selected_ids = selected_llm_model_ids_for(role)
        llm_models.select { |llm_model| selected_ids.include?(llm_model.id) }
      end
  end
end
