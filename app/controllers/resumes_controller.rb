class ResumesController < ApplicationController
  include ResumeBuilderRendering

  WORKSPACE_DEFAULT_SORT = "recently_updated".freeze

  before_action :set_resume, only: %i[ show edit update destroy duplicate export download download_text ]

  def index
    @query = params[:query].to_s.strip
    @sort = selected_workspace_sort
    @sort_options = workspace_sort_options
    @workspace_page_params = workspace_page_params
    @selected_resume_ids = selected_workspace_resume_ids

    scope = policy_scope(Resume).includes(:template).with_attached_pdf_export
    scope = scope.matching_query(@query)
    scope = sorted_workspace_scope(scope)
    @total_count = scope.count
    @per_page = 12
    @total_pages = [ (@total_count.to_f / @per_page).ceil, 1 ].max
    @current_page = [ [ params[:page].to_i, 1 ].max, @total_pages ].min
    @resumes = scope.offset((@current_page - 1) * @per_page).limit(@per_page)
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
    apply_marketplace_template
  end

  def create
    authorize Resume

    template = create_selected_template
    return render_unavailable_template_selection_on_create unless template.present?

    @resume = Resumes::Bootstrapper.new(user: current_user).call(create_resume_params(template: template))
    redirect_to edit_resume_path(@resume, step: post_create_step), notice: controller_message(:resume_created)
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
    redirect_with_workspace_alert(:resume_deleted)
  end

  def bulk_action
    authorize Resume, :bulk_action?

    resumes = selected_workspace_resumes
    return redirect_with_workspace_alert(:bulk_selection_required) if resumes.empty?

    case params[:bulk_operation].to_s
    when "export"
      resumes.each { |resume| ResumeExportJob.perform_later(resume.id, current_user.id) }
      redirect_to resumes_path(workspace_redirect_params(include_selection: false)), notice: controller_message(:bulk_export_started, count: resumes.size), status: :see_other
    when "delete"
      Resume.transaction do
        resumes.each(&:destroy!)
      end

      redirect_to resumes_path(workspace_redirect_params(include_selection: false)), notice: controller_message(:bulk_delete_completed, count: resumes.size), status: :see_other
    else
      redirect_with_workspace_alert(:bulk_action_unavailable)
    end
  end

  def bulk_download
    authorize Resume, :bulk_download?

    resumes = selected_workspace_resumes
    return redirect_with_workspace_alert(:bulk_selection_required) if resumes.empty?

    exporter = Resumes::BulkZipExporter.new(resumes: resumes)
    unless exporter.all_exports_ready?
      return redirect_to resumes_path(workspace_redirect_params), alert: controller_message(:bulk_download_not_ready, ready: exporter.ready_count, total: resumes.size), status: :see_other
    end

    send_data(
      exporter.call,
      filename: "resumes-#{Date.current.iso8601}.zip",
      type: "application/zip",
      disposition: "attachment"
    )
  end

  def duplicate
    authorize @resume

    copy = Resumes::Duplicator.new(resume: @resume).call
    redirect_to edit_resume_path(copy, step: :heading), notice: controller_message(:resume_duplicated)
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

    def apply_marketplace_template
      return unless params[:template_id].present? && params[:step].to_s == "finalize"

      new_template = Template.active.find_by(id: params[:template_id])
      return unless new_template.present?
      return if new_template.id == @resume.template_id

      @resume.update(template: new_template)
      flash.now[:notice] = controller_message(:template_applied)
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
          :font_family,
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

    def post_create_step
      @resume.source_mode == "scratch" ? "heading" : "source"
    end

    def selected_workspace_resume_ids
      ids = Array(params[:resume_ids]).filter_map(&:presence).uniq
      return [] if ids.empty?

      policy_scope(Resume).where(id: ids).pluck(:id).map(&:to_s)
    end

    def selected_workspace_resumes
      ids = selected_workspace_resume_ids
      return [] if ids.empty?

      policy_scope(Resume).where(id: ids).to_a
    end

    def workspace_redirect_params(include_selection: true)
      workspace_params = params.permit(:page, :query, :sort, resume_ids: []).to_h
      workspace_params["resume_ids"] = Array(workspace_params["resume_ids"]).filter_map(&:presence).uniq
      workspace_params.except!("resume_ids") unless include_selection
      workspace_params.compact_blank
    end

    def workspace_page_params
      params.permit(:query, :sort, resume_ids: []).to_h.compact_blank
    end

    def workspace_sort_options
      [
        { value: WORKSPACE_DEFAULT_SORT, label: I18n.t("resumes.index.sort.options.recently_updated") },
        { value: "name_asc", label: I18n.t("resumes.index.sort.options.name_asc") },
        { value: "template_asc", label: I18n.t("resumes.index.sort.options.template_asc") },
        { value: "oldest_first", label: I18n.t("resumes.index.sort.options.oldest_first") }
      ]
    end

    def selected_workspace_sort
      requested_sort = params[:sort].to_s
      workspace_sort_options.any? { |option| option.fetch(:value) == requested_sort } ? requested_sort : WORKSPACE_DEFAULT_SORT
    end

    def sorted_workspace_scope(scope)
      resume_table = Resume.arel_table
      template_table = Template.arel_table

      case @sort
      when "name_asc"
        scope.order(resume_table[:title].asc, resume_table[:updated_at].desc)
      when "template_asc"
        scope.joins(:template).order(template_table[:name].asc, resume_table[:title].asc, resume_table[:updated_at].desc)
      when "oldest_first"
        scope.order(resume_table[:created_at].asc, resume_table[:title].asc)
      else
        scope.order(resume_table[:updated_at].desc, resume_table[:title].asc)
      end
    end

    def redirect_with_workspace_alert(message_key)
      redirect_to resumes_path(workspace_redirect_params), alert: controller_message(message_key), status: :see_other
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

    def controller_message(key, **options)
      I18n.t("resumes.controller.#{key}", **options)
    end
end
