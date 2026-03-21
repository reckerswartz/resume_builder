class PhotoVerificationJob < ApplicationJob
  queue_as :default

  def perform(photo_processing_run_id, source_asset_id, resume_id, requested_by_id)
    photo_processing_run = PhotoProcessingRun.find(photo_processing_run_id)
    source_asset = PhotoAsset.find(source_asset_id)
    resume = Resume.find(resume_id)
    requested_by = User.find(requested_by_id)

    photo_processing_run.mark_running!(job_log: current_job_log)
    result = Photos::VerificationService.new(
      source_asset: source_asset,
      resume: resume,
      user: requested_by
    ).call

    unless result.success?
      photo_processing_run.mark_failed!(error_summary: result.error_message)
      track_output(photo_processing_run_id: photo_processing_run.id, error_message: result.error_message)
      raise StandardError, result.error_message
    end

    photo_processing_run.mark_succeeded!(
      response_payload: {
        "verification_feedback" => result.execution.response_text,
        "verification_metadata" => result.execution.metadata
      },
      next_step_guidance: I18n.t("resumes.editor_personal_details_step.photo_library.recent_runs.guidance.verify_candidate")
    )
    track_output(
      photo_processing_run_id: photo_processing_run.id,
      source_asset_id: source_asset.id,
      resume_id: resume.id
    )
  end

  private
    def current_job_log
      JobLog.find_by(active_job_id: job_id)
    end
end
