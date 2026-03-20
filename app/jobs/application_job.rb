class ApplicationJob < ActiveJob::Base
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  # discard_on ActiveJob::DeserializationError

  before_enqueue do |job|
    JobLog.find_or_create_by!(active_job_id: job.job_id) do |log|
      log.job_type = job.class.name
      log.queue_name = job.queue_name
      log.status = :queued
      log.input = job_input_payload(job.arguments)
    end
  end

  around_perform do |job, block|
    started_at = Time.current
    @job_log = JobLog.find_or_initialize_by(active_job_id: job.job_id)
    @job_log.assign_attributes(
      job_type: job.class.name,
      queue_name: job.queue_name,
      status: :running,
      input: job_input_payload(job.arguments),
      started_at: started_at
    )
    @job_log.save!

    block.call

    finish_job_log!(:succeeded)
  rescue StandardError => e
    failed_at = Time.current
    error_log = capture_error_log(job, e, failed_at)
    finish_job_log!(:failed, e, error_log:, finished_at: failed_at)
    raise
  end

  private
    def track_output(payload)
      @job_output = (@job_output || {}).deep_merge(payload.deep_stringify_keys)
    end

    def finish_job_log!(status, error = nil, error_log: nil, finished_at: Time.current)
      return unless @job_log

      @job_log.update!(
        status: status,
        output: @job_output || {},
        error_details: error_payload(error, error_log),
        finished_at: finished_at,
        duration_ms: duration_in_ms(@job_log.started_at || finished_at, finished_at)
      )
    end

    def capture_error_log(job, error, occurred_at)
      Errors::Tracker.capture(
        error: error,
        source: :job,
        occurred_at: occurred_at,
        duration_ms: duration_in_ms(@job_log.started_at || occurred_at, occurred_at),
        context: {
          active_job_id: job.job_id,
          job_type: job.class.name,
          queue_name: job.queue_name,
          job_log_id: @job_log&.id,
          arguments: job.arguments.as_json
        }
      )
    end

    def duration_in_ms(started_at, finished_at)
      ((finished_at - started_at) * 1000).round
    end

    def error_payload(error, error_log)
      return {} unless error

      {
        reference_id: error_log&.reference_id,
        class: error.class.name,
        message: error.message,
        backtrace: Array(error.backtrace).first(10)
      }.compact
    end

    def job_input_payload(arguments)
      { arguments: arguments.as_json }
    end
end

