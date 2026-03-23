module Admin
  module JobLogs
    class RuntimeState
      def initialize(job_log:, queue_snapshot:)
        @job_log = job_log
        @queue_snapshot = queue_snapshot
      end

      def label
        return I18n.t("admin.job_logs.helper.runtime_labels.unavailable") if queue_snapshot.unavailable?
        return queue_snapshot.state_label if queue_snapshot.found?

        I18n.t("admin.job_logs.helper.runtime_labels.missing_record")
      end

      def tone
        return :neutral if queue_snapshot.unavailable?
        return :warning if queue_snapshot.orphaned_claimed?
        return queue_state_badge_tone if queue_snapshot.found?

        :neutral
      end

      def description
        return I18n.t("admin.job_logs.helper.runtime_descriptions.unavailable") if queue_snapshot.unavailable?

        unless queue_snapshot.found?
          return I18n.t("admin.job_logs.helper.runtime_descriptions.missing_queue_record") if job_log.active_job_id.present?

          return I18n.t("admin.job_logs.helper.runtime_descriptions.missing_job_reference")
        end

        return I18n.t("admin.job_logs.helper.runtime_descriptions.worker_owner", worker: worker_label) if queue_snapshot.process.present?
        return I18n.t("admin.job_logs.helper.runtime_descriptions.orphaned_claimed") if queue_snapshot.orphaned_claimed?

        state_description
      end

      def worker_label
        return "#{queue_snapshot.process.name} (PID #{queue_snapshot.process.pid})" if queue_snapshot.process.present?
        return I18n.t("admin.job_logs.helper.worker.no_worker_attached") if queue_snapshot.orphaned_claimed?

        "N/A"
      end

      private
        attr_reader :job_log, :queue_snapshot

        def queue_state_badge_tone
          case queue_snapshot.state.to_s
          when "finished" then :success
          when "failed" then :danger
          when "running" then :warning
          when "queued", "scheduled", "blocked" then :info
          else :neutral
          end
        end

        def state_description
          key = case queue_snapshot.state.to_s
          when "failed" then "failed"
          when "finished" then "finished"
          when "scheduled" then "scheduled"
          when "blocked" then "blocked"
          when "queued" then "queued"
          when "running" then "running"
          else "default"
          end

          I18n.t("admin.job_logs.helper.runtime_descriptions.#{key}")
        end
    end
  end
end
