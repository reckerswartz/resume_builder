module Admin
  module JobLogs
    class ControlState
      def initialize(job_log:, queue_snapshot:)
        @job_log = job_log
        @queue_snapshot = queue_snapshot
      end

      def retry_available?
        queue_snapshot.retryable?
      end

      def discard_available?
        queue_snapshot.discardable?
      end

      def requeue_available?
        job_log.failed? || orphaned_running_requeue?
      end

      def requeue_label
        if orphaned_running_requeue?
          I18n.t("admin.job_logs.helper.controls.labels.return_to_pending_queue")
        else
          I18n.t("admin.job_logs.helper.controls.labels.requeue_as_new")
        end
      end

      def summary
        if retry_available? && job_log.failed?
          return I18n.t("admin.job_logs.helper.controls.summaries.retry_requeue_discard")
        end

        return I18n.t("admin.job_logs.helper.controls.summaries.retry_only") if retry_available?
        return I18n.t("admin.job_logs.helper.controls.summaries.requeue_from_failure") if job_log.failed?
        return I18n.t("admin.job_logs.helper.controls.summaries.orphaned_requeue") if orphaned_running_requeue?
        return I18n.t("admin.job_logs.helper.controls.summaries.discardable") if discard_available?

        I18n.t("admin.job_logs.helper.controls.summaries.running_locked")
      end

      def requeue_confirm
        if orphaned_running_requeue?
          I18n.t("admin.job_logs.helper.controls.confirmations.orphaned")
        elsif job_log.failed?
          I18n.t("admin.job_logs.helper.controls.confirmations.requeue_failed")
        else
          I18n.t("admin.job_logs.helper.controls.confirmations.requeue_default")
        end
      end

      def discard_confirm
        I18n.t("admin.job_logs.helper.controls.confirmations.discard")
      end

      private
        attr_reader :job_log, :queue_snapshot

        def orphaned_running_requeue?
          job_log.stale? && queue_snapshot.orphaned_claimed?
        end
    end
  end
end
