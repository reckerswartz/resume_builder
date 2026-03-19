class Admin::JobLogsController < Admin::BaseController
  def index
    @job_logs = policy_scope(JobLog).recent.limit(100)
  end

  def show
    @job_log = policy_scope(JobLog).find(params[:id])
    authorize @job_log
  end
end
