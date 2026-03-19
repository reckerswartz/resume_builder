class Admin::DashboardController < Admin::BaseController
  def show
    @resumes_count = Resume.count
    @templates_count = Template.count
    @active_templates_count = Template.active.count
    @recent_job_logs = policy_scope(JobLog).recent.limit(10)
    @platform_setting = PlatformSetting.current
  end
end
