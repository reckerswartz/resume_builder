module Admin::LlmModelsHelper
  def llm_model_badge_tone(llm_model)
    llm_model.active? ? :success : :neutral
  end

  def llm_model_badge_classes(llm_model)
    ui_badge_tone_classes(llm_model_badge_tone(llm_model))
  end

  def llm_model_source_badge_tone(llm_model)
    llm_model.provider_synced? ? :info : :neutral
  end

  def llm_model_source_badge_classes(llm_model)
    ui_badge_tone_classes(llm_model_source_badge_tone(llm_model))
  end

  def llm_model_capability_labels(llm_model)
    labels = []
    labels << llm_model.model_type_label if llm_model.model_type_label.present?
    labels << llm_models_helper_copy("capabilities.text") if llm_model.supports_text?
    labels << llm_models_helper_copy("capabilities.vision") if llm_model.supports_vision?
    labels.uniq
  end

  def llm_model_catalog_label(llm_model)
    llm_model.provider_synced? ? llm_models_helper_copy("catalog_labels.synced") : llm_models_helper_copy("catalog_labels.manual")
  end

  def llm_model_metadata_summary(llm_model)
    [ llm_model.identifier, llm_model.metadata_summary_parts.join(" · ").presence, llm_model.modality_summary ].compact_blank.join(" · ")
  end

  def llm_model_runtime_summary(llm_model)
    parts = []
    parts << llm_models_helper_copy("runtime_summary.temperature", value: llm_model.temperature) if llm_model.temperature.present?
    parts << llm_models_helper_copy("runtime_summary.max_output_tokens", count: llm_model.max_output_tokens) if llm_model.max_output_tokens.present?
    parts.presence&.join(" · ") || llm_models_helper_copy("runtime_summary.provider_defaults")
  end

  def llm_model_capability_summary(llm_model)
    llm_model_capability_labels(llm_model).to_sentence.presence || llm_models_helper_copy("capabilities.none_selected")
  end

  def llm_model_ordered_assignments(llm_model)
    Array(llm_model.llm_model_assignments).sort_by { |assignment| assignment.position || 0 }
  end

  def llm_model_assignment_summary(llm_model)
    llm_model_ordered_assignments(llm_model).map { |assignment| llm_model_role_label(assignment.role) }.to_sentence.presence || llm_models_helper_copy("assignments.unassigned")
  end

  def llm_model_assignment_badge_label(llm_model)
    llm_model.llm_model_assignments.any? ? llm_models_helper_copy("assignments.assigned") : llm_models_helper_copy("assignments.unassigned")
  end

  def llm_model_assignment_tone(llm_model)
    llm_model.llm_model_assignments.any? ? :success : :neutral
  end

  def llm_model_provider_status_label(llm_model)
    return llm_models_helper_copy("provider_status.choose_provider") if llm_model.llm_provider.blank?
    return llm_models_helper_copy("provider_status.ready") if llm_model.llm_provider.configured_for_requests?

    llm_models_helper_copy("provider_status.setup")
  end

  def llm_model_provider_status_description(llm_model)
    return llm_models_helper_copy("provider_status.select_provider_first") if llm_model.llm_provider.blank?
    return llm_models_helper_copy("provider_status.configured_for_live_requests", provider: llm_model.llm_provider.name) if llm_model.llm_provider.configured_for_requests?

    llm_models_helper_copy("provider_status.needs_provider_setup", provider: llm_model.llm_provider.name)
  end

  def llm_model_provider_status_tone(llm_model)
    return :neutral if llm_model.llm_provider.blank?

    llm_model.llm_provider.configured_for_requests? ? :success : :warning
  end

  def llm_model_orchestration_status_badge_label(llm_model)
    return llm_models_helper_copy("orchestration_status.inactive_badge") unless llm_model.active?
    return llm_models_helper_copy("provider_status.setup") unless llm_model.llm_provider.configured_for_requests?
    return llm_models_helper_copy("assignments.assigned") if llm_model.llm_model_assignments.any?

    llm_models_helper_copy("orchestration_status.ready_badge")
  end

  def llm_model_orchestration_status_label(llm_model)
    return llm_models_helper_copy("orchestration_status.inactive_detail") unless llm_model.active?
    return llm_models_helper_copy("provider_status.needs_provider_setup", provider: llm_model.llm_provider.name) unless llm_model.llm_provider.configured_for_requests?
    return llm_models_helper_copy("orchestration_status.assigned_detail", roles: llm_model_assignment_summary(llm_model)) if llm_model.llm_model_assignments.any?

    llm_models_helper_copy("orchestration_status.ready_detail")
  end

  def llm_model_orchestration_status_tone(llm_model)
    return :neutral unless llm_model.active?
    return :warning unless llm_model.llm_provider.configured_for_requests?

    :success
  end

  def llm_model_role_label(role)
    llm_models_helper_copy("assignments.role_labels.#{role}", default: role.to_s.humanize)
  end

  private
    def llm_models_helper_copy(key, **options)
      I18n.t("admin.llm_models_helper.#{key}", **options)
    end
end
