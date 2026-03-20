class Admin::DashboardController < Admin::BaseController
  def show
    @resumes_count = Resume.count
    @templates_count = Template.count
    @active_templates_count = Template.active.count
    @error_logs_count = policy_scope(ErrorLog).count
    @llm_models_count = policy_scope(LlmModel).count
    @llm_providers_count = policy_scope(LlmProvider).count
    @recent_job_logs = policy_scope(JobLog).recent.limit(10)
    @recent_error_logs = policy_scope(ErrorLog).recent.limit(10)
    @platform_setting = PlatformSetting.current
    job_monitoring = Admin::JobMonitoringService.new
    @job_log_stats = job_monitoring.job_log_stats(policy_scope(JobLog))
    @queue_overview = job_monitoring.queue_overview
  end
end
