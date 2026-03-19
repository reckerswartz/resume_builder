module ResumeBuilderRendering
  extend ActiveSupport::Concern
  include ActionView::RecordIdentifier

  private
    def render_builder_update(resume, status: :ok, notice: nil, alert: nil)
      flash.now[:notice] = notice if notice.present?
      flash.now[:alert] = alert if alert.present?

      render turbo_stream: [
        turbo_stream.replace("flash", partial: "shared/flash"),
        turbo_stream.replace(dom_id(resume, :editor), partial: "resumes/editor", locals: { resume: resume }),
        turbo_stream.replace(dom_id(resume, :preview), partial: "resumes/preview", locals: { resume: resume })
      ], status: status
    end
end
