class Admin::ErrorLogsController < Admin::BaseController
  PAGE_SIZE = 20

  def index
    @query = params[:query].to_s.strip
    @source_filter = params[:source].presence_in(ErrorLog.sources.keys).to_s
    @sort = ErrorLog.admin_sort_column(params[:sort])
    @direction = table_direction(default: "desc")

    scope = policy_scope(ErrorLog).matching_query(@query).with_source_filter(@source_filter)
    @total_count = scope.count
    @error_log_stats = {
      total: @total_count,
      request_count: scope.where(source: "request").count,
      job_count: scope.where(source: "job").count,
      with_backtrace_count: scope.where.not(backtrace_lines: []).count
    }
    @total_pages = table_total_pages(total_count: @total_count, per_page: PAGE_SIZE)
    @current_page = table_current_page(total_pages: @total_pages)
    @error_logs = scope.sorted_for_admin(@sort, @direction).offset((@current_page - 1) * PAGE_SIZE).limit(PAGE_SIZE)
  end

  def show
    @error_log = policy_scope(ErrorLog).find(params[:id])
    authorize @error_log
  end
end
