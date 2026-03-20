class ResumeSourceImportsController < ApplicationController
  before_action :authorize_launch_context
  before_action :set_provider

  def show
    @launch_feedback = Resumes::CloudImportProviderCatalog.launch_feedback(@provider.fetch(:key))
    @return_path = safe_return_path
  end

  private
    def set_provider
      @provider = Resumes::CloudImportProviderCatalog.fetch(params[:provider])
      return if @provider.present?

      redirect_to fallback_path, alert: I18n.t("resumes.resume_source_imports_controller.provider_unavailable")
    end

    def authorize_launch_context
      return if performed?

      if params[:resume_id].present?
        @resume = policy_scope(Resume).find_by(id: params[:resume_id])

        if @resume.blank?
          redirect_to resumes_path, alert: I18n.t("resumes.resume_source_imports_controller.resume_unavailable")
          return
        end

        authorize @resume, :update?
      else
        authorize Resume, :create?
      end
    end

    def safe_return_path
      requested_path = params[:return_to].to_s
      return fallback_path if requested_path.blank?
      return fallback_path unless requested_path.start_with?("/")
      return fallback_path if requested_path.start_with?("//")

      requested_path
    end

    def fallback_path
      if @resume.present?
        edit_resume_path(@resume, step: "source")
      else
        new_resume_path(step: "setup")
      end
    end
end
