class ResumesController < ApplicationController
  include ResumeBuilderRendering

  before_action :set_resume, only: %i[ show edit update destroy export download ]

  def index
    @resumes = policy_scope(Resume).includes(:template).order(updated_at: :desc)
  end

  def show
    authorize @resume
  end

  def new
    @resume = current_user.resumes.build(
      title: "Untitled Resume",
      template: Template.default!,
      contact_details: {
        "full_name" => current_user.display_name,
        "email" => current_user.email_address
      },
      settings: {
        "accent_color" => "#0F172A",
        "show_contact_icons" => true,
        "page_size" => "A4"
      }
    )
    authorize @resume
  end

  def edit
    authorize @resume
  end

  def create
    authorize Resume

    @resume = Resumes::Bootstrapper.new(user: current_user).call(create_resume_params)
    redirect_to edit_resume_path(@resume), notice: "Resume created successfully."
  rescue ActiveRecord::RecordInvalid
    @resume = build_new_resume_from_params
    authorize @resume
    flash.now[:alert] = "Unable to create resume."
    render :new, status: :unprocessable_entity
  end

  def update
    authorize @resume

    if @resume.update(update_resume_params)
      respond_to do |format|
        format.turbo_stream { render_builder_update(@resume, notice: "Resume updated.") }
        format.html { redirect_to edit_resume_path(@resume), notice: "Resume updated." }
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
      format.html { redirect_to edit_resume_path(@resume), notice: "PDF export started." }
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

  private
    def set_resume
      @resume = policy_scope(Resume).includes(sections: :entries).find(params[:id])
    end

    def create_resume_params
      permitted_resume_params.slice(:title, :headline, :summary).merge(template: create_selected_template)
    end

    def update_resume_params
      permitted_resume_params.except(:template_id).merge(template: selected_template)
    end

    def build_new_resume_from_params
      current_user.resumes.build(
        title: permitted_resume_params[:title].presence || "Untitled Resume",
        headline: permitted_resume_params[:headline],
        summary: permitted_resume_params[:summary],
        template: create_selected_template,
        contact_details: {
          "full_name" => current_user.display_name,
          "email" => current_user.email_address
        },
        settings: {
          "accent_color" => "#0F172A",
          "show_contact_icons" => true,
          "page_size" => "A4"
        }
      )
    end

    def permitted_resume_params
      permitted = params.require(:resume).permit(:title, :headline, :summary, :slug, :template_id, contact_details: {}, settings: {})
      permitted[:contact_details] = permitted[:contact_details]&.to_h || {}
      permitted[:settings] = permitted[:settings]&.to_h || {}
      permitted.to_h.symbolize_keys
    end

    def selected_template
      template_id = permitted_resume_params[:template_id]
      return @resume.template if template_id.blank?

      Template.find(template_id)
    end

    def create_selected_template
      template_id = permitted_resume_params[:template_id]
      return Template.default! if template_id.blank?

      Template.find(template_id)
    end
end
