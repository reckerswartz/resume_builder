class PhotoProfilesController < ApplicationController
  def create
    authorize PhotoProfile

    profile = PhotoProfile.default_for(current_user)
    resume_context&.update!(photo_profile: profile) if resume_context.present? && resume_context.photo_profile_id.blank?

    redirect_to return_to_path, notice: I18n.t("resumes.photo_library.controller.profile_created")
  rescue ActiveRecord::RecordInvalid => error
    redirect_to return_to_path, alert: error.record.errors.full_messages.to_sentence
  end

  private
    def resume_context
      @resume_context ||= params[:resume_id].present? ? policy_scope(Resume).find_by(id: params[:resume_id]) : nil
    end

    def return_to_path
      params[:return_to].presence ||
        (resume_context.present? ? edit_resume_path(resume_context, step: "personal_details") : resumes_path)
    end
end
