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
    return "Queue unavailable" if queue_snapshot.unavailable?
    return queue_snapshot.state_label if queue_snapshot.found?

    "Missing from queue runtime"
  end

  def job_log_runtime_tone(queue_snapshot)
    return :neutral if queue_snapshot.unavailable?
    return :warning if queue_snapshot.orphaned_claimed?
    return queue_state_badge_tone(queue_snapshot.state) if queue_snapshot.found?

    :neutral
  end

  def job_log_runtime_description(job_log, queue_snapshot)
    return queue_snapshot.error_message.presence || Admin::JobMonitoringService::QUEUE_UNAVAILABLE_MESSAGE if queue_snapshot.unavailable?

    unless queue_snapshot.found?
      return "No matching Solid Queue runtime row was found for this active job ID. The application log still contains the tracked lifecycle data below." if job_log.active_job_id.present?

      return "No active job ID was recorded for this log, so queue runtime lookup is unavailable."
    end

    return "Worker #{job_log_worker_label(queue_snapshot)} currently owns this execution." if queue_snapshot.process.present?
    return "This claimed execution no longer has a worker heartbeat and can be returned to the ready queue if needed." if queue_snapshot.orphaned_claimed?

    case queue_snapshot.state.to_s
    when "failed"
      "The queue runtime still has a failed execution row for this job."
    when "finished"
      "The queue runtime marks this job as finished."
    when "scheduled"
      "The job is scheduled and waiting for its runtime window."
    when "blocked"
      "The job is blocked by concurrency or dependency rules."
    when "queued"
      "The job is waiting in the ready queue."
    when "running"
      "The job is currently marked as running, but no worker details are attached here."
    else
      "Queue runtime data is available for this job."
    end
  end

  def job_log_worker_label(queue_snapshot)
    return "#{queue_snapshot.process.name} (PID #{queue_snapshot.process.pid})" if queue_snapshot.process.present?
    return "No worker attached" if queue_snapshot.orphaned_claimed?

    "N/A"
  end

  def job_log_related_error_reference(job_log)
    job_log.error_details["reference_id"].presence
  end

  def job_log_related_error_log(job_log)
    reference = job_log_related_error_reference(job_log)
    return if reference.blank?

    @job_log_related_error_logs ||= {}
    @job_log_related_error_logs[reference] ||= ErrorLog.find_by(reference_id: reference)
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
      "Return to ready queue"
    else
      "Requeue as new job"
    end
  end

  def job_control_summary(job_log, queue_snapshot)
    if retry_job_control_available?(queue_snapshot) && job_log.failed?
      return "Retry keeps the same active job ID, requeue creates a fresh job ID, and discard clears the failed queue row while keeping this log for debugging."
    end

    return "Retry keeps the same active job ID for a failed queue execution." if retry_job_control_available?(queue_snapshot)
    return "Requeue creates a fresh active job ID from the stored payload." if job_log.failed?
    return "This orphaned running job can be returned to the ready queue because no worker process is attached." if orphaned_running_job_requeue_available?(job_log, queue_snapshot)
    return "This queue entry can be discarded safely because no active worker currently owns it." if discard_job_control_available?(queue_snapshot)

    "Active running jobs cannot be safely mutated while a worker still owns them."
  end

  def requeue_job_control_confirm(job_log, queue_snapshot)
    if orphaned_running_job_requeue_available?(job_log, queue_snapshot)
      "Return this orphaned job to the ready queue?"
    elsif job_log.failed?
      "Create a fresh queue attempt for this failed job? The original failure log will remain available."
    else
      "Create a fresh queue attempt for this job?"
    end
  end

  def discard_job_control_confirm
    "Remove this queue entry? The application log will remain available for debugging."
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
