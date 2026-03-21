module Admin::JobLogsHelper
  def job_log_status_badge_tone(job_log)
    case job_log.status
    when "succeeded"
      :success
    when "failed"
      :danger
    when "running"
      :warning
    else
      :neutral
    end
  end

  def job_log_status_classes(job_log)
    ui_badge_tone_classes(job_log_status_badge_tone(job_log))
  end

  def queue_state_badge_tone(state)
    case state.to_s
    when "finished"
      :success
    when "failed"
      :danger
    when "running"
      :warning
    when "queued", "scheduled", "blocked"
      :info
    else
      :neutral
    end
  end

  def queue_state_classes(state)
    ui_badge_tone_classes(queue_state_badge_tone(state))
  end

  def job_duration_label(seconds)
    return "N/A" if seconds.blank?

    "#{number_with_precision(seconds, precision: 2)} seconds"
  end

  def throughput_label(count)
    "#{pluralize(count, "job")} / hour"
  end

  def job_log_runtime_label(queue_snapshot)
    return I18n.t("admin.job_logs.helper.runtime_labels.unavailable") if queue_snapshot.unavailable?
    return queue_snapshot.state_label if queue_snapshot.found?

    I18n.t("admin.job_logs.helper.runtime_labels.missing_record")
  end

  def job_log_runtime_tone(queue_snapshot)
    return :neutral if queue_snapshot.unavailable?
    return :warning if queue_snapshot.orphaned_claimed?
    return queue_state_badge_tone(queue_snapshot.state) if queue_snapshot.found?

    :neutral
  end

  def job_log_runtime_description(job_log, queue_snapshot)
    return I18n.t("admin.job_logs.helper.runtime_descriptions.unavailable") if queue_snapshot.unavailable?

    unless queue_snapshot.found?
      return I18n.t("admin.job_logs.helper.runtime_descriptions.missing_queue_record") if job_log.active_job_id.present?

      return I18n.t("admin.job_logs.helper.runtime_descriptions.missing_job_reference")
    end

    return I18n.t("admin.job_logs.helper.runtime_descriptions.worker_owner", worker: job_log_worker_label(queue_snapshot)) if queue_snapshot.process.present?
    return I18n.t("admin.job_logs.helper.runtime_descriptions.orphaned_claimed") if queue_snapshot.orphaned_claimed?

    case queue_snapshot.state.to_s
    when "failed"
      I18n.t("admin.job_logs.helper.runtime_descriptions.failed")
    when "finished"
      I18n.t("admin.job_logs.helper.runtime_descriptions.finished")
    when "scheduled"
      I18n.t("admin.job_logs.helper.runtime_descriptions.scheduled")
    when "blocked"
      I18n.t("admin.job_logs.helper.runtime_descriptions.blocked")
    when "queued"
      I18n.t("admin.job_logs.helper.runtime_descriptions.queued")
    when "running"
      I18n.t("admin.job_logs.helper.runtime_descriptions.running")
    else
      I18n.t("admin.job_logs.helper.runtime_descriptions.default")
    end
  end

  def job_log_worker_label(queue_snapshot)
    return "#{queue_snapshot.process.name} (PID #{queue_snapshot.process.pid})" if queue_snapshot.process.present?
    return I18n.t("admin.job_logs.helper.worker.no_worker_attached") if queue_snapshot.orphaned_claimed?

    "N/A"
  end

  def job_log_related_error_state(job_log)
    related_error_logs = @job_log_related_error_logs || {}
    reference = job_log.error_details.to_h["reference_id"].presence
    error_log_loaded = reference.blank? || related_error_logs.key?(reference)

    Admin::JobLogs::RelatedErrorState.new(
      job_log: job_log,
      error_log: related_error_logs[reference],
      error_log_loaded: error_log_loaded
    )
  end

  def formatted_debug_payload(value)
    JSON.pretty_generate(normalized_debug_payload(value))
  end

  def retry_job_control_available?(queue_snapshot)
    queue_snapshot.retryable?
  end

  def discard_job_control_available?(queue_snapshot)
    queue_snapshot.discardable?
  end

  def requeue_job_control_available?(job_log, queue_snapshot)
    job_log.failed? || orphaned_running_job_requeue_available?(job_log, queue_snapshot)
  end

  def requeue_job_control_label(job_log, queue_snapshot)
    if orphaned_running_job_requeue_available?(job_log, queue_snapshot)
      I18n.t("admin.job_logs.helper.controls.labels.return_to_pending_queue")
    else
      I18n.t("admin.job_logs.helper.controls.labels.requeue_as_new")
    end
  end

  def job_control_summary(job_log, queue_snapshot)
    if retry_job_control_available?(queue_snapshot) && job_log.failed?
      return I18n.t("admin.job_logs.helper.controls.summaries.retry_requeue_discard")
    end

    return I18n.t("admin.job_logs.helper.controls.summaries.retry_only") if retry_job_control_available?(queue_snapshot)
    return I18n.t("admin.job_logs.helper.controls.summaries.requeue_from_failure") if job_log.failed?
    return I18n.t("admin.job_logs.helper.controls.summaries.orphaned_requeue") if orphaned_running_job_requeue_available?(job_log, queue_snapshot)
    return I18n.t("admin.job_logs.helper.controls.summaries.discardable") if discard_job_control_available?(queue_snapshot)

    I18n.t("admin.job_logs.helper.controls.summaries.running_locked")
  end

  def requeue_job_control_confirm(job_log, queue_snapshot)
    if orphaned_running_job_requeue_available?(job_log, queue_snapshot)
      I18n.t("admin.job_logs.helper.controls.confirmations.orphaned")
    elsif job_log.failed?
      I18n.t("admin.job_logs.helper.controls.confirmations.requeue_failed")
    else
      I18n.t("admin.job_logs.helper.controls.confirmations.requeue_default")
    end
  end

  def discard_job_control_confirm
    I18n.t("admin.job_logs.helper.controls.confirmations.discard")
  end

  private
    def orphaned_running_job_requeue_available?(job_log, queue_snapshot)
      job_log.stale? && queue_snapshot.orphaned_claimed?
    end

    def normalized_debug_payload(value)
      case value
      when nil
        {}
      when Hash
        value.as_json.deep_stringify_keys
      when Array
        value.as_json
      else
        { "value" => value.as_json }
      end
    end
end
