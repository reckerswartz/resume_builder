module Admin
  module JobLogs
    class RelatedErrorState
      def initialize(job_log:, error_log: nil, error_log_loaded: false)
        @job_log = job_log
        @error_log = error_log
        @error_log_loaded = error_log_loaded
      end

      def reference
        job_log.error_details.to_h["reference_id"].presence
      end

      def error_log
        return @error_log if error_log_loaded?

        @error_log = reference.present? ? ErrorLog.find_by(reference_id: reference) : nil
        @error_log_loaded = true
        @error_log
      end

      def tracked?
        reference.present? || job_log.failed?
      end

      def description
        return I18n.t("admin.job_logs.helper.related_error_descriptions.available") if error_log.present?
        return I18n.t("admin.job_logs.helper.related_error_descriptions.reference_only") if reference.present?
        return I18n.t("admin.job_logs.helper.related_error_descriptions.failed_without_reference") if job_log.failed?

        I18n.t("admin.job_logs.helper.related_error_descriptions.none")
      end

      private
        attr_reader :job_log

        def error_log_loaded?
          @error_log_loaded
        end
    end
  end
end
