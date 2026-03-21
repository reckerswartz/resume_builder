module Admin
  class SettingsPageState
    HUB_SECTIONS = [
      { id: "feature-access", label: "Feature access", caption: "Rollout and feature gating" }.freeze,
      { id: "platform-defaults", label: "Platform defaults", caption: "Default template and support contact" }.freeze,
      { id: "cloud-import-connectors", label: "Cloud import connectors", caption: "Provider readiness and environment checks" }.freeze,
      { id: "llm-orchestration", label: "LLM orchestration", caption: "Generation and verification workflows" }.freeze
    ].freeze

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
        eyebrow: "Admin settings",
        title: "Platform settings",
        description: "Control feature access, platform defaults, cloud-import readiness, and model assignments from one shared admin surface.",
        badges: [
          { label: "#{enabled_feature_count}/#{feature_flags.size} enabled", tone: :neutral },
          { label: "#{llm_providers_count} providers", tone: :neutral },
          { label: "#{llm_models.count} models", tone: :neutral }
        ],
        actions: [
          { label: "Manage templates", path: view_context.admin_templates_path, style: :secondary },
          { label: "Manage providers", path: view_context.admin_llm_providers_path, style: :secondary },
          { label: "Manage models", path: view_context.admin_llm_models_path, style: :primary }
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
      HUB_SECTIONS
    end

    def workflow_ready_count
      @workflow_ready_count ||= [ text_primary_model.present?, vision_primary_model.present? ].count(true)
    end

    def save_posture_ready?
      workflow_ready_count == 2 && configured_cloud_import_provider_count == cloud_import_provider_states.size
    end

    private
      attr_reader :llm_assignment_model_ids, :platform_setting, :view_context

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
