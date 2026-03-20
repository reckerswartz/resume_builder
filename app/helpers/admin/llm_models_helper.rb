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
    labels << "Text" if llm_model.supports_text?
    labels << "Vision" if llm_model.supports_vision?
    labels.uniq
  end

  def llm_model_catalog_label(llm_model)
    llm_model.provider_synced? ? "Synced catalog" : "Manual catalog"
  end

  def llm_model_metadata_summary(llm_model)
    [ llm_model.identifier, llm_model.metadata_summary_parts.join(" · ").presence, llm_model.modality_summary ].compact_blank.join(" · ")
  end

  def llm_model_runtime_summary(llm_model)
    parts = []
    parts << "Temp #{llm_model.temperature}" if llm_model.temperature.present?
    parts << "#{llm_model.max_output_tokens} max tokens" if llm_model.max_output_tokens.present?
    parts.presence&.join(" · ") || "Provider defaults"
  end

  def llm_model_capability_summary(llm_model)
    llm_model_capability_labels(llm_model).to_sentence.presence || "No capabilities selected"
  end

  def llm_model_ordered_assignments(llm_model)
    Array(llm_model.llm_model_assignments).sort_by { |assignment| assignment.position || 0 }
  end

  def llm_model_assignment_summary(llm_model)
    llm_model_ordered_assignments(llm_model).map { |assignment| assignment.role.humanize }.to_sentence.presence || "Unassigned"
  end

  def llm_model_assignment_badge_label(llm_model)
    llm_model.llm_model_assignments.any? ? "Assigned" : "Unassigned"
  end

  def llm_model_assignment_tone(llm_model)
    llm_model.llm_model_assignments.any? ? :success : :neutral
  end

  def llm_model_provider_status_label(llm_model)
    return "Choose a provider" if llm_model.llm_provider.blank?
    return "Provider ready" if llm_model.llm_provider.configured_for_requests?

    "Provider setup"
  end

  def llm_model_provider_status_description(llm_model)
    return "Select a provider before saving this model." if llm_model.llm_provider.blank?
    return "#{llm_model.llm_provider.name} is configured for live requests." if llm_model.llm_provider.configured_for_requests?

    "#{llm_model.llm_provider.name} still needs provider setup before this model can serve live requests."
  end

  def llm_model_provider_status_tone(llm_model)
    return :neutral if llm_model.llm_provider.blank?

    llm_model.llm_provider.configured_for_requests? ? :success : :warning
  end

  def llm_model_orchestration_status_badge_label(llm_model)
    return "Inactive" unless llm_model.active?
    return "Provider setup" unless llm_model.llm_provider.configured_for_requests?
    return "Assigned" if llm_model.llm_model_assignments.any?

    "Ready"
  end

  def llm_model_orchestration_status_label(llm_model)
    return "Inactive models remain in the catalog but are ignored by ready-model selection." unless llm_model.active?
    return "#{llm_model.llm_provider.name} still needs provider setup before this model can serve live requests." unless llm_model.llm_provider.configured_for_requests?
    return "Assigned to #{llm_model_assignment_summary(llm_model)}." if llm_model.llm_model_assignments.any?

    "Ready to be assigned from the settings hub."
  end

  def llm_model_orchestration_status_tone(llm_model)
    return :neutral unless llm_model.active?
    return :warning unless llm_model.llm_provider.configured_for_requests?

    :success
  end
end
