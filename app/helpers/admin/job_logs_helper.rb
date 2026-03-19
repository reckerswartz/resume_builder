module Admin::JobLogsHelper
  def job_log_status_classes(job_log)
    case job_log.status
    when "succeeded"
      "bg-emerald-50 text-emerald-700 border border-emerald-200"
    when "failed"
      "bg-rose-50 text-rose-700 border border-rose-200"
    when "running"
      "bg-amber-50 text-amber-700 border border-amber-200"
    else
      "bg-slate-100 text-slate-600 border border-slate-200"
    end
  end
end
