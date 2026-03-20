class Admin::JobLogsController < Admin::BaseController
  PAGE_SIZE = 20

  before_action :set_job_log, only: %i[ show retry discard requeue ]

  def index
    @query = params[:query].to_s.strip
    @status_filter = params[:status].presence_in(JobLog.statuses.keys).to_s
    @sort = JobLog.admin_sort_column(params[:sort])
    @direction = table_direction(default: "desc")
    @job_monitoring = Admin::JobMonitoringService.new

    scope = policy_scope(JobLog).matching_query(@query).with_status_filter(@status_filter)
    @job_log_stats = @job_monitoring.job_log_stats(scope)
    @queue_overview = @job_monitoring.queue_overview
    @exact_match_job_log = @query.present? ? policy_scope(JobLog).reorder(created_at: :desc).find_by(active_job_id: @query) : nil
    @total_count = scope.count
    @total_pages = table_total_pages(total_count: @total_count, per_page: PAGE_SIZE)
    @current_page = table_current_page(total_pages: @total_pages)
    @job_logs = scope.sorted_for_admin(@sort, @direction).offset((@current_page - 1) * PAGE_SIZE).limit(PAGE_SIZE)
    preload_related_error_logs(@job_logs)
  end

  def show
    authorize @job_log
    @queue_snapshot = Admin::JobMonitoringService.new.queue_snapshot_for(@job_log.active_job_id)
  end

  def retry
    authorize @job_log, :retry?
    handle_control_result(Admin::JobControlService.new(job_log: @job_log).retry)
  end

  def discard
    authorize @job_log, :discard?
    handle_control_result(Admin::JobControlService.new(job_log: @job_log).discard)
  end

  def requeue
    authorize @job_log, :requeue?
    handle_control_result(Admin::JobControlService.new(job_log: @job_log).requeue)
  end

  private
    def set_job_log
      @job_log = policy_scope(JobLog).find(params[:id])
    end

    def preload_related_error_logs(job_logs)
      references = job_logs.filter_map { |job_log| job_log.error_details["reference_id"].presence }.uniq
      return @job_log_related_error_logs = {} if references.empty?

      loaded_error_logs = policy_scope(ErrorLog).where(reference_id: references).index_by(&:reference_id)
      @job_log_related_error_logs = references.index_with { |reference| loaded_error_logs[reference] }
    end

    def handle_control_result(result)
      flash_type = result.success? ? :notice : :alert
      redirect_to admin_job_log_path(result.redirect_job_log || @job_log), flash_type => result.message, status: :see_other
    end
end
