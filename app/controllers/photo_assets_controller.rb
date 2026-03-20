class PhotoAssetsController < ApplicationController
  before_action :set_photo_profile
  before_action :set_photo_asset, only: %i[destroy background_remove generate_for_template verify]

  def create
    authorize @photo_profile, :update?

    result = Photos::UploadIngestionService.new(
      user: current_user,
      uploaded_files: upload_files,
      photo_profile: @photo_profile
    ).call

    if result.success?
      resume_context&.update!(photo_profile: @photo_profile) if resume_context.present? && resume_context.photo_profile_id.blank?
      redirect_to return_to_path, notice: upload_notice(result)
    else
      redirect_to return_to_path, alert: result.error_message
    end
  end

  def destroy
    authorize @photo_asset

    reset_selected_source_asset!
    @photo_asset.destroy!
    redirect_to return_to_path, notice: I18n.t("resumes.photo_library.controller.photo_deleted")
  end

  def background_remove
    authorize @photo_asset, :update?
    return redirect_to(return_to_path, alert: generation_unavailable_message) unless generation_enabled?

    run = @photo_profile.photo_processing_runs.create!(
      workflow_type: :background_remove,
      status: :queued,
      resume: resume_context,
      template: resume_context&.template,
      input_asset_ids: [ @photo_asset.id ],
      selected_model_ids: LlmModelAssignment.ready_models_for("vision_generation").map(&:id)
    )
    PhotoBackgroundRemovalJob.perform_later(run.id, @photo_asset.id, current_user.id, resume_context&.id)

    redirect_to return_to_path, notice: I18n.t("resumes.photo_library.controller.background_removal_started")
  end

  def generate_for_template
    authorize @photo_asset, :update?
    return redirect_to(return_to_path, alert: generation_unavailable_message) unless generation_enabled?
    return redirect_to(return_to_path, alert: I18n.t("resumes.photo_library.controller.resume_required")) if resume_context.blank?

    run = @photo_profile.photo_processing_runs.create!(
      workflow_type: :generate_for_template,
      status: :queued,
      resume: resume_context,
      template: resume_context.template,
      input_asset_ids: [ @photo_asset.id ],
      selected_model_ids: LlmModelAssignment.ready_models_for("vision_generation").map(&:id)
    )
    ResumeTemplateImageGenerationJob.perform_later(run.id, @photo_asset.id, resume_context.id, current_user.id)

    redirect_to return_to_path, notice: I18n.t("resumes.photo_library.controller.generation_started")
  end

  def verify
    authorize @photo_asset, :update?
    return redirect_to(return_to_path, alert: verification_unavailable_message) unless verification_enabled?
    return redirect_to(return_to_path, alert: I18n.t("resumes.photo_library.controller.resume_required")) if resume_context.blank?

    run = @photo_profile.photo_processing_runs.create!(
      workflow_type: :verify_candidate,
      status: :queued,
      resume: resume_context,
      template: resume_context.template,
      input_asset_ids: [ @photo_asset.id ],
      selected_model_ids: LlmModelAssignment.ready_models_for("vision_verification").map(&:id)
    )
    PhotoVerificationJob.perform_later(run.id, @photo_asset.id, resume_context.id, current_user.id)

    redirect_to return_to_path, notice: I18n.t("resumes.photo_library.controller.verification_started")
  end

  private
    def set_photo_profile
      @photo_profile = policy_scope(PhotoProfile).find(params[:photo_profile_id])
    end

    def set_photo_asset
      @photo_asset = policy_scope(PhotoAsset).find(params[:id])
    end

    def resume_context
      @resume_context ||= params[:resume_id].present? ? policy_scope(Resume).find_by(id: params[:resume_id]) : nil
    end

    def return_to_path
      params[:return_to].presence ||
        (resume_context.present? ? edit_resume_path(resume_context, step: "personal_details") : resumes_path)
    end

    def upload_files
      params.fetch(:photo_assets, {}).fetch(:files, [])
    end

    def generation_enabled?
      feature_enabled?("resume_image_generation") && llm_role_enabled?("vision_generation")
    end

    def generation_unavailable_message
      I18n.t("resumes.photo_library.controller.generation_unavailable")
    end

    def reset_selected_source_asset!
      return unless @photo_profile.selected_source_photo_asset_id == @photo_asset.id

      replacement_asset = @photo_profile.photo_assets.where.not(id: @photo_asset.id).ready_for_library.latest_first.first
      @photo_profile.update!(selected_source_photo_asset: replacement_asset)
    end

    def upload_notice(result)
      parts = []
      parts << I18n.t("resumes.photo_library.controller.upload_started", count: result.created_assets.size) if result.created_assets.any?
      parts << I18n.t("resumes.photo_library.controller.duplicates_skipped", count: result.duplicate_assets.size) if result.duplicate_assets.any?
      parts << result.errors.to_sentence if result.errors.any?
      parts.to_sentence
    end

    def verification_enabled?
      feature_enabled?("resume_image_generation") && llm_role_enabled?("vision_verification")
    end

    def verification_unavailable_message
      I18n.t("resumes.photo_library.controller.verification_unavailable")
    end
end
