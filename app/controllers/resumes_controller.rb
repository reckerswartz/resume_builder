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
    flash.now[:alert] = controller_message(:template_unavailable) if params[:template_id].present? && initial_template.blank?

    @resume = build_resume_draft(
      template: initial_template || builder_default_template,
      attributes: {
        intake_details: requested_new_intake_details,
        settings: requested_new_settings
      }
    )
    flash.now[:alert] = controller_message(:choose_experience_level_first) if params[:step].to_s == "student" && @resume.experience_level != "less_than_3_years"
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
    redirect_to edit_resume_path(@resume, step: "source"), notice: controller_message(:resume_created)
  rescue ActiveRecord::RecordInvalid
    @resume = build_new_resume_from_params
    authorize @resume
    flash.now[:alert] = controller_message(:unable_to_create)
    render :new, status: :unprocessable_entity
  end

  def update
    authorize @resume

    template = selected_template
    return render_unavailable_template_selection_on_update unless template.present?

    if @resume.update(update_resume_params(template: template))
      selection_success, selection_error_message = persist_headshot_selection
      unless selection_success
        @resume.errors.add(:base, selection_error_message)
        respond_to do |format|
          format.turbo_stream { render_builder_update(@resume, status: :unprocessable_entity, alert: selection_error_message) }
          format.html { render :edit, status: :unprocessable_entity }
        end
        return
      end

      purge_headshot_if_requested
      @resume.reload

      return respond_to_autofill if run_autofill_requested?

      respond_to do |format|
        format.turbo_stream { render_builder_update(@resume, notice: controller_message(:resume_updated)) }
        format.html { redirect_to edit_resume_path(@resume, **builder_step_redirect_params), notice: controller_message(:resume_updated) }
      end
    else
      respond_to_failed_update
    end
  end

  def destroy
    authorize @resume

    @resume.destroy!
    redirect_to resumes_path, notice: controller_message(:resume_deleted), status: :see_other
  end

  def export
    authorize @resume

    ResumeExportJob.perform_later(@resume.id, current_user.id)

    respond_to do |format|
      format.turbo_stream { render_builder_update(@resume, notice: controller_message(:pdf_export_started_turbo)) }
      format.html { redirect_to edit_resume_path(@resume, **builder_step_redirect_params), notice: controller_message(:pdf_export_started) }
    end
  end

  def download
    authorize @resume

    if @resume.pdf_export.attached?
      redirect_to rails_blob_path(@resume.pdf_export, disposition: "attachment")
    else
      redirect_to edit_resume_path(@resume), alert: controller_message(:pdf_export_unavailable)
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
      @resume = policy_scope(Resume)
        .includes(:photo_profile, { resume_photo_selections: :photo_asset }, { sections: :entries })
        .find(params[:id])
    end

    def respond_to_autofill
      result = Llm::ResumeAutofillService.new(user: current_user, resume: @resume).call

      respond_to do |format|
        if result.success?
          format.turbo_stream { render_builder_update(result.resume, notice: controller_message(:source_applied)) }
          format.html { redirect_to edit_resume_path(result.resume, **builder_step_redirect_params), notice: controller_message(:source_applied) }
        else
          format.turbo_stream { render_builder_update(@resume.reload, alert: result.error_message) }
          format.html { redirect_to edit_resume_path(@resume, **builder_step_redirect_params), alert: result.error_message }
        end
      end
    end

    def create_resume_params(template:)
      draft_resume_attributes.merge(template: template)
    end

    def update_resume_params(template:)
      permitted_resume_params.except(:template_id, :remove_headshot, :selected_headshot_photo_asset_id).merge(template: template)
    end

    def update_resume(template:)
      return false unless @resume.update(update_resume_params(template: template))

      purge_headshot_if_requested
      true
    end

    def respond_to_successful_update
      return respond_to_autofill if run_autofill_requested?

      respond_to do |format|
        format.turbo_stream { render_builder_update(@resume, notice: controller_message(:resume_updated)) }
        format.html { redirect_to edit_resume_path(@resume, **builder_step_redirect_params), notice: controller_message(:resume_updated) }
      end
    end

    def respond_to_failed_update
      respond_to do |format|
        format.turbo_stream { render_builder_update(@resume, status: :unprocessable_entity, alert: controller_message(:review_highlighted_errors)) }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end

    def build_new_resume_from_params
      build_resume_draft(
        template: create_selected_template || builder_default_template,
        attributes: draft_resume_attributes
      )
    end

    def draft_resume_attributes
      permitted_resume_params.slice(:title, :headline, :summary, :source_mode, :source_text, :source_document, :headshot, :settings, :intake_details, :personal_details)
    end

    def build_resume_draft(template:, attributes: {})
      Resumes::DraftBuilder.new(user: current_user, template: template, attributes: attributes).call
    end

    def permitted_resume_params
      permitted = params.require(:resume).permit(
        :title,
        :headline,
        :summary,
        :slug,
        :template_id,
        :photo_profile_id,
        :selected_headshot_photo_asset_id,
        :source_mode,
        :source_text,
        :source_document,
        :headshot,
        :remove_headshot,
        contact_details: {},
        settings: [
          :accent_color,
          :page_size,
          :show_contact_icons,
          :font_scale,
          :density,
          :section_spacing,
          :paragraph_spacing,
          :line_spacing,
          { hidden_sections: [] }
        ],
        intake_details: %i[experience_level student_status],
        personal_details: Resume::PERSONAL_DETAIL_FIELDS.map(&:to_sym)
      )
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

    def remove_headshot_requested?
      ActiveModel::Type::Boolean.new.cast(permitted_resume_params[:remove_headshot])
    end

    def persist_headshot_selection
      raw_resume_params = params.fetch(:resume, {})
      selected_asset_param_present = raw_resume_params.respond_to?(:key?) && raw_resume_params.key?(:selected_headshot_photo_asset_id)
      return [ true, nil ] unless selected_asset_param_present

      selected_asset_id = permitted_resume_params[:selected_headshot_photo_asset_id].presence
      selected_photo_asset = selected_asset_id.present? ? policy_scope(PhotoAsset).find_by(id: selected_asset_id) : nil
      return [ false, I18n.t("resumes.controller.selected_photo_unavailable") ] if selected_asset_id.present? && selected_photo_asset.blank?

      selection_result = Photos::SelectionService.new(
        resume: @resume,
        photo_asset: selected_photo_asset,
        template: @resume.template
      ).call
      [ selection_result.success?, selection_result.error_message ]
    end

    def purge_headshot_if_requested
      return unless remove_headshot_requested?
      return unless permitted_resume_params[:headshot].blank?
      return unless @resume.headshot.attached?

      @resume.headshot.purge
      @resume.reload
    end

    def selected_template
      template_id = permitted_resume_params[:template_id]
      return @resume.template if template_id.blank? || template_id.to_s == @resume.template_id.to_s

      selectable_template_for_selection(template_id)
    end

    def create_selected_template
      template_id = permitted_resume_params[:template_id]
      return builder_default_template if template_id.blank?

      selectable_template_for_selection(template_id)
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

      selectable_template_for_selection(template_id)
    end

    def selectable_template_for_selection(template_id)
      Template.active.find_by(id: template_id)
    end

    def requested_new_intake_details
      raw_details = params.fetch(:resume, {}).fetch(:intake_details, {})
      raw_details = raw_details.to_unsafe_h if raw_details.respond_to?(:to_unsafe_h)

      raw_details
        .to_h
        .deep_stringify_keys
        .slice("experience_level", "student_status")
    end

    def requested_new_settings
      raw_settings = params.fetch(:resume, {}).fetch(:settings, {})
      raw_settings = raw_settings.to_unsafe_h if raw_settings.respond_to?(:to_unsafe_h)

      raw_settings
        .to_h
        .deep_stringify_keys
        .slice("accent_color")
    end

    def render_unavailable_template_selection_on_create
      @resume = build_new_resume_from_params
      @resume.errors.add(:template, controller_message(:template_selection_unavailable_error))
      authorize @resume
      flash.now[:alert] = controller_message(:choose_available_template)
      render :new, status: :unprocessable_entity
    end

    def render_unavailable_template_selection_on_update
      @resume.errors.add(:template, controller_message(:template_selection_unavailable_error))

      respond_to do |format|
        format.turbo_stream { render_builder_update(@resume, status: :unprocessable_entity, alert: controller_message(:choose_available_template)) }
        format.html { render :edit, status: :unprocessable_entity }
      end
    end

    def controller_message(key)
      I18n.t("resumes.controller.#{key}")
    end
end
