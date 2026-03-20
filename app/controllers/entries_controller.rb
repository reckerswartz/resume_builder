class EntriesController < ApplicationController
  include ResumeBuilderRendering

  before_action :set_resume
  before_action :set_section
  before_action :set_entry, only: %i[ update destroy move improve ]

  def create
    authorize @resume, :update?

    @entry = @section.entries.build(content: normalized_content)

    if @entry.save
      respond_to_success(I18n.t("resumes.entries_controller.created"))
    else
      respond_to_failure(@entry)
    end
  end

  def update
    authorize @resume, :update?

    if @entry.update(content: normalized_content)
      respond_to_success(I18n.t("resumes.entries_controller.updated"))
    else
      respond_to_failure(@entry)
    end
  end

  def destroy
    authorize @resume, :update?

    @entry.destroy!
    respond_to_success(I18n.t("resumes.entries_controller.destroyed"))
  end

  def move
    authorize @resume, :update?

    Resumes::PositionMover.new(record: @entry, direction: params[:direction], position: params[:position]).call
    respond_to_success(I18n.t("resumes.entries_controller.moved"))
  end

  def improve
    authorize @resume, :update?

    result = Llm::ResumeSuggestionService.new(user: current_user, entry: @entry).call

    if result.success? && @entry.update(content: result.content)
      respond_to_success(I18n.t("resumes.entries_controller.improved"))
    else
      respond_to do |format|
        format.turbo_stream { render_builder_update(@resume, status: :unprocessable_entity, alert: result.error_message || I18n.t("resumes.entries_controller.improve_unavailable")) }
        format.html { redirect_to edit_resume_path(@resume), alert: result.error_message || I18n.t("resumes.entries_controller.improve_unavailable") }
      end
    end
  end

  private
    def set_resume
      @resume = policy_scope(Resume).includes(sections: :entries).find(params[:resume_id])
    end

    def set_section
      @section = @resume.sections.find(params[:section_id])
    end

    def set_entry
      @entry = @section.entries.find(params[:id])
    end

    def normalized_content
      Resumes::EntryContentNormalizer.new(section_type: @section.section_type, params: entry_content_params).call
    end

    def entry_content_params
      params.require(:entry).permit(content: {})[:content]&.to_h || {}
    end

    def respond_to_success(message)
      respond_to do |format|
        format.turbo_stream { render_builder_update(@resume, notice: message) }
        format.html { redirect_to edit_resume_path(@resume), notice: message }
      end
    end

    def respond_to_failure(entry)
      respond_to do |format|
        format.turbo_stream { render_builder_update(@resume, status: :unprocessable_entity, alert: entry.errors.full_messages.to_sentence) }
        format.html do
          flash.now[:alert] = entry.errors.full_messages.to_sentence
          render "resumes/edit", status: :unprocessable_entity
        end
      end
    end
end
