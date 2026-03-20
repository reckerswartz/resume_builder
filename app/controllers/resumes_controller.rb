class ResumesController < ApplicationController
  include ResumeBuilderRendering

  before_action :set_resume, only: %i[ show edit update destroy export download download_text ]

  def index
    @resumes = policy_scope(Resume).includes(:template).order(updated_at: :desc)
  end

  def show
    authorize @resume
  end

  def new
    initial_template = requested_new_template
    flash.now[:alert] = "Template is not available." if params[:template_id].present? && initial_template.blank?

    @resume = current_user.resumes.build(
      title: "Untitled Resume",
      template: initial_template || builder_default_template,
      source_mode: "scratch",
      source_text: "",
      contact_details: {
        "full_name" => current_user.display_name,
        "email" => current_user.email_address
      },
      intake_details: requested_new_intake_details,
      personal_details: {},
      settings: {
        "accent_color" => "#0F172A",
        "show_contact_icons" => true,
        "page_size" => "A4"
      }
    )
    flash.now[:alert] = "Choose your experience level first." if params[:step].to_s == "student" && @resume.experience_level != "less_than_3_years"
    authorize @resume
  end

  def edit
    authorize @resume
  end

  def create
    authorize Resume

    template = create_selected_template
    return render_unavailable_template_selection_on_create unless template.present?

    @resume = Resumes::Bootstrapper.new(user: current_user).call(create_resume_params(template: template))
    redirect_to edit_resume_path(@resume, step: "source"), notice: "Resume created successfully."
  rescue ActiveRecord::RecordInvalid
    @resume = build_new_resume_from_params
    authorize @resume
    flash.now[:alert] = "Unable to create resume."
    render :new, status: :unprocessable_entity
  end

  def update
    authorize @resume

    template = selected_template
    return render_unavailable_template_selection_on_update unless template.present?

    if @resume.update(update_resume_params(template: template))
      return respond_to_autofill if run_autofill_requested?

      respond_to do |format|
        format.turbo_stream { render_builder_update(@resume, notice: "Resume updated.") }
        format.html { redirect_to edit_resume_path(@resume, **builder_step_redirect_params), notice: "Resume updated." }
      end
    else
      respond_to do |format|
        format.turbo_stream { render_builder_update(@resume, status: :unprocessable_entity, alert: "Please review the highlighted errors.") }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @resume

    @resume.destroy!
    redirect_to resumes_path, notice: "Resume deleted.", status: :see_other
  end

  def export
    authorize @resume

    ResumeExportJob.perform_later(@resume.id, current_user.id)

    respond_to do |format|
      format.turbo_stream { render_builder_update(@resume, notice: "PDF export started. Refresh in a moment to download the latest file.") }
      format.html { redirect_to edit_resume_path(@resume, **builder_step_redirect_params), notice: "PDF export started." }
    end
  end

  def download
    authorize @resume

    if @resume.pdf_export.attached?
      redirect_to rails_blob_path(@resume.pdf_export, disposition: "attachment")
    else
      redirect_to edit_resume_path(@resume), alert: "No PDF export is available yet."
    end
  end

  def download_text
    authorize @resume, :download?

    send_data(
      Resumes::TextExporter.new(resume: @resume).call,
      filename: "#{@resume.slug}.txt",
      type: "text/plain; charset=utf-8",
      disposition: "attachment"
    )
  end

  private
    def set_resume
      @resume = policy_scope(Resume).includes(sections: :entries).find(params[:id])
    end

    def respond_to_autofill
      result = Llm::ResumeAutofillService.new(user: current_user, resume: @resume).call

      respond_to do |format|
        if result.success?
          format.turbo_stream { render_builder_update(result.resume, notice: "Source text applied to the draft.") }
          format.html { redirect_to edit_resume_path(result.resume, **builder_step_redirect_params), notice: "Source text applied to the draft." }
        else
          format.turbo_stream { render_builder_update(@resume.reload, alert: result.error_message) }
          format.html { redirect_to edit_resume_path(@resume, **builder_step_redirect_params), alert: result.error_message }
        end
      end
    end

    def create_resume_params(template:)
      permitted_resume_params.slice(:title, :headline, :summary, :source_mode, :source_text, :source_document, :intake_details, :personal_details).merge(template: template)
    end

    def update_resume_params(template:)
      permitted_resume_params.except(:template_id).merge(template: template)
    end

    def build_new_resume_from_params
      current_user.resumes.build(
        title: permitted_resume_params[:title].presence || "Untitled Resume",
        headline: permitted_resume_params[:headline],
        summary: permitted_resume_params[:summary],
        source_mode: permitted_resume_params[:source_mode].presence || "scratch",
        source_text: permitted_resume_params[:source_text].to_s,
        source_document: permitted_resume_params[:source_document],
        template: create_selected_template || builder_default_template,
        contact_details: {
          "full_name" => current_user.display_name,
          "email" => current_user.email_address
        },
        intake_details: permitted_resume_params[:intake_details] || {},
        personal_details: permitted_resume_params[:personal_details] || {},
        settings: {
          "accent_color" => "#0F172A",
          "show_contact_icons" => true,
          "page_size" => "A4"
        }
      )
    end

    def permitted_resume_params
      permitted = params.require(:resume).permit(:title, :headline, :summary, :slug, :template_id, :source_mode, :source_text, :source_document, contact_details: {}, settings: {}, intake_details: %i[experience_level student_status], personal_details: Resume::PERSONAL_DETAIL_FIELDS.map(&:to_sym))
      permitted[:contact_details] = permitted[:contact_details].to_h if permitted[:contact_details]
      permitted[:settings] = permitted[:settings].to_h if permitted[:settings]
      permitted[:intake_details] = permitted[:intake_details].to_h if permitted[:intake_details]
      permitted[:personal_details] = permitted[:personal_details].to_h if permitted[:personal_details]
      permitted.to_h.symbolize_keys
    end

    def builder_step_redirect_params
      return {} if params[:step].blank?

      { step: params[:step] }
    end

    def run_autofill_requested?
      ActiveModel::Type::Boolean.new.cast(params[:run_autofill])
    end

    def selected_template
      template_id = permitted_resume_params[:template_id]
      return @resume.template if template_id.blank? || template_id.to_s == @resume.template_id.to_s

      selectable_template_scope.find_by(id: template_id)
    end

    def create_selected_template
      template_id = permitted_resume_params[:template_id]
      return builder_default_template if template_id.blank?

      selectable_template_scope.find_by(id: template_id)
    end

    def selectable_template_scope
      @selectable_template_scope ||= Template.user_visible
    end

    def builder_default_template
      @builder_default_template ||= selectable_template_scope.order(:created_at).first || Template.default!
    end

    def requested_new_template
      template_id = params[:template_id].presence
      return if template_id.blank?

      selectable_template_scope.find_by(id: template_id)
    end

    def requested_new_intake_details
      raw_details = params.fetch(:resume, {}).fetch(:intake_details, {})
      raw_details = raw_details.to_unsafe_h if raw_details.respond_to?(:to_unsafe_h)

      raw_details
        .to_h
        .deep_stringify_keys
        .slice("experience_level", "student_status")
    end

    def render_unavailable_template_selection_on_create
      @resume = build_new_resume_from_params
      @resume.errors.add(:template, "is not available.")
      authorize @resume
      flash.now[:alert] = "Choose a template that is still available."
      render :new, status: :unprocessable_entity
    end

    def render_unavailable_template_selection_on_update
      @resume.errors.add(:template, "is not available.")

      respond_to do |format|
        format.turbo_stream { render_builder_update(@resume, status: :unprocessable_entity, alert: "Choose a template that is still available.") }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end
end
