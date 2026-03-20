module Admin
  class JobControlService
    Result = Struct.new(:success, :message, :redirect_job_log, keyword_init: true) do
      def success?
        success
      end
    end

    def initialize(job_log:, queue_snapshot: nil, monitoring_service: JobMonitoringService.new)
      @job_log = job_log
      @monitoring_service = monitoring_service
      @queue_snapshot = queue_snapshot
    end

    def retry
      return failure(queue_unavailable_message) if queue_snapshot.unavailable?
      return failure("Retry is only available for failed queue jobs.") unless queue_snapshot.retryable?

      queue_snapshot.failed_execution.retry
      success("Retry requested for #{job_log.active_job_id}.")
    rescue StandardError => error
      handle_error(:retry, error)
    end

    def discard
      return failure(queue_unavailable_message) if queue_snapshot.unavailable?

      execution = discardable_execution
      return failure("Discard is only available for queued, scheduled, blocked, or failed queue jobs.") unless execution

      execution.discard
      mark_discarded!(occurred_at: Time.current)
      success("Job discarded from the queue.")
    rescue StandardError => error
      handle_error(:discard, error)
    end

    def requeue
      return requeue_failed_job if requeue_failed_job?
      return release_orphaned_claimed_job if requeue_orphaned_claimed_job?

      failure("Requeue is only available for failed jobs or orphaned running jobs.")
    rescue StandardError => error
      handle_error(:requeue, error)
    end

    private
      attr_reader :job_log, :monitoring_service

      def queue_snapshot
        @queue_snapshot ||= monitoring_service.queue_snapshot_for(job_log.active_job_id)
      end

      def discardable_execution
        queue_snapshot.ready_execution || queue_snapshot.scheduled_execution || queue_snapshot.blocked_execution || queue_snapshot.failed_execution
      end

      def requeue_failed_job?
        job_log.failed?
      end

      def requeue_orphaned_claimed_job?
        job_log.stale? && !queue_snapshot.unavailable? && queue_snapshot.orphaned_claimed?
      end

      def requeue_failed_job
        job_class = resolved_job_class
        return failure("This job class can no longer be loaded for requeueing.") unless job_class

        arguments = deserialized_arguments
        return failure("The original job arguments could not be reconstructed for requeueing.") if arguments.nil?

        enqueue_options = { queue: job_log.queue_name, priority: queue_snapshot.job&.priority }.compact
        new_job = job_class.set(**enqueue_options).perform_later(*arguments)
        success(
          "Requeued as a new job (#{new_job.job_id}).",
          redirect_job_log: JobLog.find_by(active_job_id: new_job.job_id) || job_log
        )
      end

      def release_orphaned_claimed_job
        queue_snapshot.claimed_execution.release
        success("Orphaned running job returned to the ready queue.")
      end

      def resolved_job_class
        class_name = queue_snapshot.job&.class_name || job_log.job_type
        job_class = class_name.safe_constantize
        job_class if job_class && job_class <= ActiveJob::Base
      end

      def deserialized_arguments
        serialized_arguments = queue_snapshot.job&.arguments&.dig("arguments")
        serialized_arguments = job_log.input["arguments"] unless serialized_arguments.is_a?(Array)
        return unless serialized_arguments.is_a?(Array)

        ActiveJob::Arguments.deserialize(serialized_arguments)
      rescue StandardError
        nil
      end

      def mark_discarded!(occurred_at:)
        return if job_log.failed? && job_log.finished_at.present?

        error_details = job_log.error_details.is_a?(Hash) ? job_log.error_details.deep_dup : {}
        error_details["admin_action"] = {
          "action" => "discard",
          "performed_at" => occurred_at.iso8601,
          "message" => "Discarded from the queue by an admin"
        }

        job_log.update!(
          status: :failed,
          finished_at: occurred_at,
          duration_ms: job_log.duration_ms || duration_in_ms(job_log.started_at || occurred_at, occurred_at),
          error_details: error_details
        )
      end

      def duration_in_ms(started_at, finished_at)
        ((finished_at - started_at) * 1000).round
      end

      def queue_unavailable_message
        queue_snapshot.error_message.presence || JobMonitoringService::QUEUE_UNAVAILABLE_MESSAGE
      end

      def success(message, redirect_job_log: job_log)
        Result.new(success: true, message: message, redirect_job_log: redirect_job_log)
      end

      def failure(message, redirect_job_log: job_log)
        Result.new(success: false, message: message, redirect_job_log: redirect_job_log)
      end

      def handle_error(action, error)
        Rails.logger.error(
          "admin_job_control_failed action=#{action} job_log_id=#{job_log.id} active_job_id=#{job_log.active_job_id} error_class=#{error.class.name} error_message=#{error.message}"
        )
        failure("Could not #{action} the job. #{error.message}")
      end
  end
end
