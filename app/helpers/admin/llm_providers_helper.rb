module Admin::LlmProvidersHelper
  def llm_provider_badge_tone(llm_provider)
    llm_provider.active? ? :success : :neutral
  end

  def llm_provider_badge_classes(llm_provider)
    ui_badge_tone_classes(llm_provider_badge_tone(llm_provider))
  end

  def llm_provider_sync_badge_tone(llm_provider)
    case llm_provider.sync_status
    when :synced
      :success
    when :error
      :warning
    else
      :neutral
    end
  end

  def llm_provider_sync_badge_classes(llm_provider)
    ui_badge_tone_classes(llm_provider_sync_badge_tone(llm_provider))
  end

  def llm_provider_adapter_label(llm_provider)
    llm_provider.adapter.humanize
  end

  def llm_provider_sync_label(llm_provider)
    case llm_provider.sync_status
    when :synced
      llm_provider.last_synced_at.present? ? "Synced #{time_ago_in_words(llm_provider.last_synced_at)} ago" : "Synced"
    when :error
      "Sync error"
    else
      "Not synced"
    end
  end

  def llm_provider_sync_tone(llm_provider)
    case llm_provider.sync_status
    when :synced
      :success
    when :error
      :warning
    else
      :neutral
    end
  end

  def llm_provider_credential_summary(llm_provider)
    return "Not required" unless llm_provider.nvidia_build?
    return "API key not configured" if llm_provider.api_key_reference.blank?

    label = llm_provider.api_key_reference_type == "env_var" ? "Env var" : "Direct token"
    "#{label} · #{llm_provider.masked_api_key_reference}"
  end

  def llm_provider_request_status_label(llm_provider)
    return "Ready" if llm_provider.configured_for_requests?
    return "Inactive" unless llm_provider.active?

    llm_provider.syncability_error || "Setup needed"
  end

  def llm_provider_request_badge_label(llm_provider)
    return "Ready" if llm_provider.configured_for_requests?
    return "Inactive" unless llm_provider.active?

    "Needs setup"
  end

  def llm_provider_request_status_tone(llm_provider)
    return :success if llm_provider.configured_for_requests?
    return :neutral unless llm_provider.active?

    :warning
  end

  def llm_provider_credential_status_label(llm_provider)
    return "Not required" unless llm_provider.nvidia_build?
    return "Missing credential" if llm_provider.api_key_reference.blank?
    return "Env var ready" if llm_provider.api_key_reference_type == "env_var" && llm_provider.api_key.present?
    return "Env var unresolved" if llm_provider.api_key_reference_type == "env_var"

    "Direct token stored"
  end

  def llm_provider_credential_status_tone(llm_provider)
    return :neutral unless llm_provider.nvidia_build?
    return :warning if llm_provider.api_key_reference.blank?
    return :success if llm_provider.api_key_reference_type == "env_var" && llm_provider.api_key.present?

    :warning
  end

  def llm_provider_sync_summary(llm_provider)
    return llm_provider.last_sync_error if llm_provider.last_sync_error.present?
    return "Synced #{time_ago_in_words(llm_provider.last_synced_at)} ago" if llm_provider.last_synced_at.present?

    "No catalog sync has completed yet."
  end

  def llm_provider_model_badge_tone(llm_model)
    llm_model.active? ? :success : :neutral
  end

  def llm_provider_model_badge_classes(llm_model)
    ui_badge_tone_classes(llm_provider_model_badge_tone(llm_model))
  end
end
