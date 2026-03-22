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

  def job_log_runtime_state(job_log, queue_snapshot)
    Admin::JobLogs::RuntimeState.new(job_log: job_log, queue_snapshot: queue_snapshot)
  end

  def job_log_runtime_label(queue_snapshot)
    job_log_runtime_state(JobLog.new, queue_snapshot).label
  end

  def job_log_runtime_tone(queue_snapshot)
    job_log_runtime_state(JobLog.new, queue_snapshot).tone
  end

  def job_log_runtime_description(job_log, queue_snapshot)
    job_log_runtime_state(job_log, queue_snapshot).description
  end

  def job_log_worker_label(queue_snapshot)
    job_log_runtime_state(JobLog.new, queue_snapshot).worker_label
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

  def job_log_control_state(job_log, queue_snapshot)
    Admin::JobLogs::ControlState.new(job_log: job_log, queue_snapshot: queue_snapshot)
  end

  def retry_job_control_available?(queue_snapshot)
    queue_snapshot.retryable?
  end

  def discard_job_control_available?(queue_snapshot)
    queue_snapshot.discardable?
  end

  def requeue_job_control_available?(job_log, queue_snapshot)
    job_log_control_state(job_log, queue_snapshot).requeue_available?
  end

  def requeue_job_control_label(job_log, queue_snapshot)
    job_log_control_state(job_log, queue_snapshot).requeue_label
  end

  def job_control_summary(job_log, queue_snapshot)
    job_log_control_state(job_log, queue_snapshot).summary
  end

  def requeue_job_control_confirm(job_log, queue_snapshot)
    job_log_control_state(job_log, queue_snapshot).requeue_confirm
  end

  def discard_job_control_confirm
    Admin::JobLogs::ControlState.new(job_log: JobLog.new, queue_snapshot: nil).discard_confirm
  end

  private

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
