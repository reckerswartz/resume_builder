module ResumeBuilderRendering
  extend ActiveSupport::Concern
  include ActionView::RecordIdentifier

  private
    def render_builder_update(resume, status: :ok, notice: nil, alert: nil)
      builder_state = view_context.resume_builder_editor_state(resume)
      preview_state = view_context.resume_builder_preview_state(resume)

      flash.now[:notice] = notice if notice.present?
      flash.now[:alert] = alert if alert.present?

      turbo_streams = [
        turbo_stream.replace("flash", partial: "shared/flash")
      ]

      if builder_state.step_partial != "editor_section_step"
        workspace_state = view_context.resume_builder_workspace_state(resume)
        turbo_streams << turbo_stream.replace(dom_id(resume, :workspace_overview), partial: "resumes/workspace_overview", locals: { resume: resume, workspace_state: workspace_state })
      end

      turbo_streams.concat([
        turbo_stream.replace(dom_id(resume, :editor_chrome), partial: "resumes/editor_chrome", locals: { resume: resume, builder_state: builder_state }),
        turbo_stream.replace(dom_id(resume, :editor_step_content), partial: "resumes/editor_step_content", locals: { resume: resume, builder_state: builder_state }),
        turbo_stream.replace(dom_id(resume, :preview), partial: "resumes/preview", locals: { resume: resume, preview_state: preview_state })
      ])

      render turbo_stream: turbo_streams, status: status
    end
end
