class Admin::JobLogsController < Admin::BaseController
  PAGE_SIZE = 20

  before_action :set_job_log, only: %i[ show retry discard requeue ]

  def index
    @query = params[:query].to_s.strip
    @status_filter = params[:status].presence_in(JobLog.statuses.keys).to_s
    @sort = JobLog.admin_sort_column(params[:sort])
    @direction = table_direction(default: "desc")

    result = Admin::JobLogsIndexService.new(
      job_log_scope: policy_scope(JobLog),
      error_log_scope: policy_scope(ErrorLog),
      query: @query,
      status_filter: @status_filter,
      sort: @sort,
      direction: @direction,
      requested_page: params[:page],
      per_page: PAGE_SIZE
    ).call

    @job_log_stats = result.job_log_stats
    @queue_overview = result.queue_overview
    @exact_match_job_log = result.exact_match_job_log
    @total_count = result.total_count
    @total_pages = result.total_pages
    @current_page = result.current_page
    @job_logs = result.job_logs
    @job_log_related_error_logs = result.related_error_logs
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

    def handle_control_result(result)
      flash_type = result.success? ? :notice : :alert
      redirect_to admin_job_log_path(result.redirect_job_log || @job_log), flash_type => result.message, status: :see_other
    end
end
