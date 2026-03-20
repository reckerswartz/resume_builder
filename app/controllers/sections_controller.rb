class SectionsController < ApplicationController
  include ResumeBuilderRendering

  before_action :set_resume
  before_action :set_section, only: %i[ update destroy move ]

  def create
    authorize @resume, :update?

    @section = @resume.sections.build(section_params)

    if @section.save
      respond_to_success("Section added.")
    else
      respond_to_failure(@section)
    end
  end

  def update
    authorize @resume, :update?

    if @section.update(section_params)
      respond_to_success("Section updated.")
    else
      respond_to_failure(@section)
    end
  end

  def destroy
    authorize @resume, :update?

    @section.destroy!
    respond_to_success("Section removed.")
  end

  def move
    authorize @resume, :update?

    Resumes::PositionMover.new(record: @section, direction: params[:direction], position: params[:position]).call
    respond_to_success("Section order updated.")
  end

  private
    def set_resume
      @resume = policy_scope(Resume).includes(sections: :entries).find(params[:resume_id])
    end

    def set_section
      @section = @resume.sections.find(params[:id])
    end

    def section_params
      permitted = params.require(:section).permit(:title, :section_type, settings: {})
      permitted[:settings] = permitted[:settings]&.to_h || {}
      permitted.to_h
    end

    def respond_to_success(message)
      respond_to do |format|
        format.turbo_stream { render_builder_update(@resume, notice: message) }
        format.html { redirect_to edit_resume_path(@resume), notice: message }
      end
    end

    def respond_to_failure(section)
      respond_to do |format|
        format.turbo_stream { render_builder_update(@resume, status: :unprocessable_entity, alert: section.errors.full_messages.to_sentence) }
        format.html do
          flash.now[:alert] = section.errors.full_messages.to_sentence
          render "resumes/edit", status: :unprocessable_entity
        end
      end
    end
end
