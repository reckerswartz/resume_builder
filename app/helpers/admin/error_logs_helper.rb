module Admin::ErrorLogsHelper
  def error_log_source_badge_tone(error_log)
    case error_log.source
    when "job"
      :warning
    else
      :info
    end
  end

  def error_log_source_classes(error_log)
    ui_badge_tone_classes(error_log_source_badge_tone(error_log))
  end

  def error_log_source_label(error_log)
    error_log.source.humanize
  end

  def error_log_source_description(error_log)
    if error_log.job?
      I18n.t("admin.error_logs.helper.source_descriptions.job")
    else
      I18n.t("admin.error_logs.helper.source_descriptions.request")
    end
  end

  def error_log_duration_label(error_log)
    return "N/A" if error_log.duration_ms.blank?

    "#{number_with_precision(error_log.duration_seconds, precision: 2)} seconds"
  end

  def error_log_request_summary(error_log)
    [ error_log.context["method"].presence, error_log.context["path"].presence ].compact.join(" ").presence
  end

  def error_log_primary_reference_label(error_log)
    if error_log.job?
      error_log.context["active_job_id"].presence || I18n.t("admin.error_logs.helper.primary_reference_labels.missing_job")
    else
      error_log.context["request_id"].presence || I18n.t("admin.error_logs.helper.primary_reference_labels.missing_request")
    end
  end

  def error_log_primary_reference_description(error_log)
    if error_log.job?
      [
        error_log.context["job_type"].presence,
        (I18n.t("admin.error_logs.helper.primary_reference_descriptions.queue", queue_name: error_log.context["queue_name"]) if error_log.context["queue_name"].present?)
      ].compact.join(" · ").presence || I18n.t("admin.error_logs.helper.primary_reference_descriptions.missing_job")
    else
      [
        error_log_request_summary(error_log),
        (I18n.t("admin.error_logs.helper.primary_reference_descriptions.user", user_id: error_log.context["user_id"]) if error_log.context["user_id"].present?)
      ].compact.join(" · ").presence || I18n.t("admin.error_logs.helper.primary_reference_descriptions.missing_request")
    end
  end

  def error_log_related_job_log(error_log)
    job_log_id = error_log.context["job_log_id"].presence
    return if job_log_id.blank?

    @error_log_related_job_logs ||= {}
    @error_log_related_job_logs[job_log_id] ||= JobLog.find_by(id: job_log_id)
  end

  def error_log_related_job_label(error_log)
    related_job_log = error_log_related_job_log(error_log)
    return related_job_log.active_job_id if related_job_log&.active_job_id.present?
    return I18n.t("admin.error_logs.helper.related_job.fallback", id: error_log.context["job_log_id"]) if error_log.context["job_log_id"].present?

    error_log.context["active_job_id"].presence || I18n.t("admin.error_logs.helper.related_job.none")
  end
end
