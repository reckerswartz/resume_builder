class ResumeTemplateImageGenerationJob < ApplicationJob
  queue_as :default

  def perform(photo_processing_run_id, source_asset_id, resume_id, requested_by_id)
    photo_processing_run = PhotoProcessingRun.find(photo_processing_run_id)
    source_asset = PhotoAsset.find(source_asset_id)
    resume = Resume.find(resume_id)
    requested_by = User.find(requested_by_id)

    photo_processing_run.mark_running!(job_log: current_job_log)
    result = Photos::GenerationOrchestrator.new(
      photo_profile: source_asset.photo_profile,
      source_asset: source_asset,
      resume: resume,
      template: resume.template,
      user: requested_by
    ).call

    unless result.success?
      photo_processing_run.mark_failed!(
        error_summary: result.error_message,
        response_payload: { "prompt_text" => result.prompt_text }
      )
      track_output(photo_processing_run_id: photo_processing_run.id, error_message: result.error_message)
      raise StandardError, result.error_message
    end

    photo_processing_run.mark_succeeded!(
      output_asset_ids: result.assets.map(&:id),
      response_payload: {
        "prompt_text" => result.prompt_text,
        "generated_asset_ids" => result.assets.map(&:id)
      },
      next_step_guidance: "Generated portrait candidates are ready for review and selection."
    )
    track_output(
      photo_processing_run_id: photo_processing_run.id,
      source_asset_id: source_asset.id,
      resume_id: resume.id,
      output_asset_ids: result.assets.map(&:id)
    )
  end

  private
    def current_job_log
      JobLog.find_by(active_job_id: job_id)
    end
end
