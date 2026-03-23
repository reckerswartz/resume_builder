class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]

  def new
    @user = User.new
    load_template_selection_context
  end

  def create
    @user = User.new(user_params)
    @user.role = nil
    load_template_selection_context

    if @user.save
      Resumes::Bootstrapper.new(user: @user).call(starter_resume_attributes) if @user.resumes.empty?
      start_new_session_for(@user)
      redirect_to resumes_path, notice: I18n.t("registrations.controller.workspace_ready")
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
    def load_template_selection_context
      @selected_template = requested_template
      @starter_resume_intake_details = requested_resume_intake_details
      @selected_template_accent_color = requested_resume_settings["accent_color"].presence if @selected_template.present?
    end

    def starter_resume_attributes
      attributes = {}
      attributes[:template] = @selected_template if @selected_template.present?
      attributes[:intake_details] = @starter_resume_intake_details if @starter_resume_intake_details.present?
      if @selected_template.present? && @selected_template_accent_color.present?
        attributes[:settings] = { "accent_color" => @selected_template_accent_color }
      end
      attributes
    end

    def requested_template
      template_id = params[:template_id].presence
      return if template_id.blank?

      Template.user_visible.find_by(id: template_id)
    end

    def requested_resume_intake_details
      raw_details = params.fetch(:resume, {}).fetch(:intake_details, {})
      raw_details = raw_details.to_unsafe_h if raw_details.respond_to?(:to_unsafe_h)

      raw_details
        .to_h
        .deep_stringify_keys
        .slice("experience_level", "student_status")
        .compact_blank
    end

    def requested_resume_settings
      raw_settings = params.fetch(:resume, {}).fetch(:settings, {})
      raw_settings = raw_settings.to_unsafe_h if raw_settings.respond_to?(:to_unsafe_h)

      raw_settings
        .to_h
        .deep_stringify_keys
        .slice("accent_color")
        .compact_blank
    end

    def user_params
      params.require(:user).permit(:email_address, :password, :password_confirmation)
    end
end
