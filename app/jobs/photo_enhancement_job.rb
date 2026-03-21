class PhotoEnhancementJob < ApplicationJob
  queue_as :default

  def perform(photo_processing_run_id, source_asset_id)
    photo_processing_run = PhotoProcessingRun.find(photo_processing_run_id)
    source_asset = PhotoAsset.find(source_asset_id)

    photo_processing_run.mark_running!(job_log: current_job_log)
    result = Photos::EnhancementService.new(source_asset: source_asset).call

    unless result.success?
      photo_processing_run.mark_failed!(error_summary: result.error_message, response_payload: result.metadata)
      track_output(photo_processing_run_id: photo_processing_run.id, error_message: result.error_message)
      raise StandardError, result.error_message
    end

    photo_processing_run.mark_succeeded!(
      output_asset_ids: [ result.asset.id ],
      response_payload: result.metadata,
      next_step_guidance: I18n.t("resumes.editor_personal_details_step.photo_library.recent_runs.guidance.enhance")
    )
    track_output(
      photo_processing_run_id: photo_processing_run.id,
      source_asset_id: source_asset.id,
      output_asset_ids: [ result.asset.id ]
    )
  end

  private
    def current_job_log
      JobLog.find_by(active_job_id: job_id)
    end
end
