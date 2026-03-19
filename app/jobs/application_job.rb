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
      log.input = serialize_arguments(job.arguments)
    end
  end

  around_perform do |job, block|
    started_at = Time.current
    @job_log = JobLog.find_or_initialize_by(active_job_id: job.job_id)
    @job_log.assign_attributes(
      job_type: job.class.name,
      queue_name: job.queue_name,
      status: :running,
      input: serialize_arguments(job.arguments),
      started_at: started_at
    )
    @job_log.save!

    block.call

    finish_job_log!(:succeeded)
  rescue StandardError => e
    finish_job_log!(:failed, e)
    raise
  end

  private
    def track_output(payload)
      @job_output = (@job_output || {}).deep_merge(payload.deep_stringify_keys)
    end

    def finish_job_log!(status, error = nil)
      return unless @job_log

      finished_at = Time.current
      @job_log.update!(
        status: status,
        output: @job_output || {},
        error_details: error_payload(error),
        finished_at: finished_at,
        duration_ms: duration_in_ms(@job_log.started_at || finished_at, finished_at)
      )
    end

    def duration_in_ms(started_at, finished_at)
      ((finished_at - started_at) * 1000).round
    end

    def error_payload(error)
      return {} unless error

      {
        class: error.class.name,
        message: error.message,
        backtrace: Array(error.backtrace).first(10)
      }
    end

    def serialize_arguments(arguments)
      arguments.as_json
    end
end
