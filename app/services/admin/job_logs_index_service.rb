module Admin
  class JobLogsIndexService
    Result = Data.define(
      :job_log_stats,
      :queue_overview,
      :exact_match_job_log,
      :total_count,
      :total_pages,
      :current_page,
      :job_logs,
      :related_error_logs
    )

    def initialize(job_log_scope:, error_log_scope:, query:, status_filter:, sort:, direction:, requested_page:, per_page:, monitoring_service: Admin::JobMonitoringService.new)
      @job_log_scope = job_log_scope
      @error_log_scope = error_log_scope
      @query = query
      @status_filter = status_filter
      @sort = sort
      @direction = direction
      @requested_page = requested_page
      @per_page = per_page.to_i.positive? ? per_page.to_i : 20
      @monitoring_service = monitoring_service
    end

    def call
      scope = filtered_job_logs
      total_count = scope.count
      total_pages = resolved_total_pages(total_count)
      current_page = resolved_current_page(total_pages)
      job_logs = scope.sorted_for_admin(sort, direction).offset((current_page - 1) * per_page).limit(per_page)

      Result.new(
        job_log_stats: monitoring_service.job_log_stats(scope),
        queue_overview: monitoring_service.queue_overview,
        exact_match_job_log: exact_match_job_log,
        total_count: total_count,
        total_pages: total_pages,
        current_page: current_page,
        job_logs: job_logs,
        related_error_logs: related_error_logs_for(job_logs)
      )
    end

    private
      attr_reader :direction, :error_log_scope, :job_log_scope, :monitoring_service, :per_page, :query, :requested_page, :sort, :status_filter

      def filtered_job_logs
        job_log_scope.matching_query(query).with_status_filter(status_filter)
      end

      def exact_match_job_log
        return if query.blank?

        job_log_scope.reorder(created_at: :desc).find_by(active_job_id: query)
      end

      def related_error_logs_for(job_logs)
        references = job_logs.filter_map { |job_log| job_log.error_details["reference_id"].presence }.uniq
        return {} if references.empty?

        loaded_error_logs = error_log_scope.where(reference_id: references).index_by(&:reference_id)
        references.index_with { |reference| loaded_error_logs[reference] }
      end

      def resolved_total_pages(total_count)
        [ (total_count.to_f / per_page).ceil, 1 ].max
      end

      def resolved_current_page(total_pages)
        page = requested_page.to_i
        page = 1 if page < 1
        [ page, total_pages ].min
      end
  end
end
