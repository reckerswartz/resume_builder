module LlmProvider::SyncState
  extend ActiveSupport::Concern

  def syncable?
    return false if base_url.blank?
    return true unless nvidia_build?

    api_key.present?
  end

  def syncability_error
    return if syncable?
    return I18n.t("llm_provider.syncability_error.needs_api_key", name: name) if nvidia_build? && api_key_reference.blank?
    return I18n.t("llm_provider.syncability_error.unresolved_env_var", name: name, reference: api_key_reference) if nvidia_build? && api_key_reference_type == "env_var"

    I18n.t("llm_provider.syncability_error.not_ready", name: name)
  end

  def configured_for_requests?
    return false unless active?

    syncable?
  end

  def last_synced_at
    parse_settings_time("last_synced_at")
  end

  def last_sync_attempt_at
    parse_settings_time("last_sync_attempt_at")
  end

  def last_synced_model_count
    count = settings["last_synced_model_count"]
    count.present? ? count.to_i : nil
  end

  def last_sync_error
    settings["last_sync_error"].presence
  end

  def sync_status
    return :error if last_sync_error.present?
    return :synced if last_synced_at.present?

    :never_synced
  end

  private
    def parse_settings_time(key)
      value = settings[key].presence
      return if value.blank?

      Time.zone.parse(value)
    rescue ArgumentError, TypeError
      nil
    end
end
