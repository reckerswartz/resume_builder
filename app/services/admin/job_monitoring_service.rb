module Admin
  class JobMonitoringService
    STALE_JOB_THRESHOLD = 15.minutes
    STALE_PROCESS_THRESHOLD = 2.minutes
    QUEUE_MODELS = %w[
      SolidQueue::Job
      SolidQueue::ReadyExecution
      SolidQueue::ClaimedExecution
      SolidQueue::FailedExecution
      SolidQueue::ScheduledExecution
      SolidQueue::BlockedExecution
      SolidQueue::Process
    ].freeze
    QUEUE_UNAVAILABLE_MESSAGE = "Solid Queue runtime data is unavailable in this environment."
    QUEUE_ERRORS = [
      ActiveRecord::AdapterNotSpecified,
      ActiveRecord::ConnectionNotEstablished,
      ActiveRecord::NoDatabaseError,
      ActiveRecord::StatementInvalid
    ].freeze

    JobLogStats = Struct.new(
      :total,
      :queued,
      :running,
      :succeeded,
      :failed,
      :completed,
      :failure_rate,
      :average_duration_seconds,
      :completed_last_hour,
      :stale_running,
      keyword_init: true
    )

    QueueOverview = Struct.new(
      :available,
      :queued,
      :running,
      :failed,
      :scheduled,
      :blocked,
      :processes,
      :stale_processes,
      :error_message,
      keyword_init: true
    ) do
      def unavailable?
        !available
      end

      def backlog
        queued.to_i + scheduled.to_i + blocked.to_i
      end
    end

    QueueSnapshot = Struct.new(
      :available,
      :job,
      :state,
      :ready_execution,
      :claimed_execution,
      :failed_execution,
      :scheduled_execution,
      :blocked_execution,
      :process,
      :error_message,
      keyword_init: true
    ) do
      def unavailable?
        !available
      end

      def found?
        job.present?
      end

      def state_label
        state.to_s.humanize
      end

      def retryable?
        failed_execution.present?
      end

      def discardable?
        failed_execution.present? || ready_execution.present? || scheduled_execution.present? || blocked_execution.present?
      end

      def orphaned_claimed?
        claimed_execution.present? && process.blank?
      end
    end

    def job_log_stats(scope)
      relation = normalize_scope(scope)
      status_counts = relation.group(:status).count
      completed = status_counts.fetch("succeeded", 0) + status_counts.fetch("failed", 0)
      average_duration_ms = relation.where.not(duration_ms: nil).average(:duration_ms)
      current_time = Time.current

      JobLogStats.new(
        total: relation.count,
        queued: status_counts.fetch("queued", 0),
        running: status_counts.fetch("running", 0),
        succeeded: status_counts.fetch("succeeded", 0),
        failed: status_counts.fetch("failed", 0),
        completed: completed,
        failure_rate: completed.positive? ? (status_counts.fetch("failed", 0) * 100.0 / completed) : 0.0,
        average_duration_seconds: average_duration_ms&.to_f&./(1000.0),
        completed_last_hour: relation.where(status: %w[succeeded failed], finished_at: (current_time - 1.hour)..current_time).count,
        stale_running: relation.running.where(started_at: ..(current_time - STALE_JOB_THRESHOLD)).count
      )
    end

    def queue_overview
      return unavailable_queue_overview unless queue_tables_available?

      current_time = Time.current

      QueueOverview.new(
        available: true,
        queued: SolidQueue::ReadyExecution.count,
        running: SolidQueue::ClaimedExecution.count,
        failed: SolidQueue::FailedExecution.count,
        scheduled: SolidQueue::ScheduledExecution.count,
        blocked: SolidQueue::BlockedExecution.count,
        processes: SolidQueue::Process.count,
        stale_processes: SolidQueue::Process.where(last_heartbeat_at: ..(current_time - STALE_PROCESS_THRESHOLD)).count,
        error_message: nil
      )
    rescue *QUEUE_ERRORS => error
      unavailable_queue_overview(error.message)
    end

    def queue_snapshot_for(active_job_id)
      return unavailable_queue_snapshot unless queue_tables_available?
      return QueueSnapshot.new(available: true, job: nil, state: :missing, error_message: nil) if active_job_id.blank?

      queue_job = SolidQueue::Job.find_by(active_job_id: active_job_id)
      return QueueSnapshot.new(available: true, job: nil, state: :missing, error_message: nil) unless queue_job

      failed_execution = SolidQueue::FailedExecution.find_by(job_id: queue_job.id)
      claimed_execution = SolidQueue::ClaimedExecution.includes(:process).find_by(job_id: queue_job.id)
      ready_execution = SolidQueue::ReadyExecution.find_by(job_id: queue_job.id)
      scheduled_execution = SolidQueue::ScheduledExecution.find_by(job_id: queue_job.id)
      blocked_execution = SolidQueue::BlockedExecution.find_by(job_id: queue_job.id)

      QueueSnapshot.new(
        available: true,
        job: queue_job,
        state: queue_state_for(
          queue_job: queue_job,
          ready_execution: ready_execution,
          claimed_execution: claimed_execution,
          failed_execution: failed_execution,
          scheduled_execution: scheduled_execution,
          blocked_execution: blocked_execution
        ),
        ready_execution: ready_execution,
        claimed_execution: claimed_execution,
        failed_execution: failed_execution,
        scheduled_execution: scheduled_execution,
        blocked_execution: blocked_execution,
        process: claimed_execution&.process,
        error_message: nil
      )
    rescue *QUEUE_ERRORS => error
      unavailable_queue_snapshot(error.message)
    end

    private
      def normalize_scope(scope)
        scope.except(:limit, :offset, :order)
      end

      def queue_tables_available?
        queue_models.size == QUEUE_MODELS.size && queue_models.all?(&:table_exists?)
      rescue *QUEUE_ERRORS
        false
      end

      def queue_models
        @queue_models ||= QUEUE_MODELS.filter_map(&:safe_constantize)
      end

      def queue_state_for(queue_job:, ready_execution:, claimed_execution:, failed_execution:, scheduled_execution:, blocked_execution:)
        return :failed if failed_execution.present?
        return :running if claimed_execution.present?
        return :queued if ready_execution.present?
        return :scheduled if scheduled_execution.present?
        return :blocked if blocked_execution.present?
        return :finished if queue_job.finished_at.present?

        :unknown
      end

      def unavailable_queue_overview(message = QUEUE_UNAVAILABLE_MESSAGE)
        QueueOverview.new(
          available: false,
          queued: 0,
          running: 0,
          failed: 0,
          scheduled: 0,
          blocked: 0,
          processes: 0,
          stale_processes: 0,
          error_message: message.presence || QUEUE_UNAVAILABLE_MESSAGE
        )
      end

      def unavailable_queue_snapshot(message = QUEUE_UNAVAILABLE_MESSAGE)
        QueueSnapshot.new(
          available: false,
          job: nil,
          state: :unavailable,
          ready_execution: nil,
          claimed_execution: nil,
          failed_execution: nil,
          scheduled_execution: nil,
          blocked_execution: nil,
          process: nil,
          error_message: message.presence || QUEUE_UNAVAILABLE_MESSAGE
        )
      end
  end
end
