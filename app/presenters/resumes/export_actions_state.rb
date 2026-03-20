module Resumes
  class ExportActionsState
    def initialize(resume:, context:, view_context:)
      @resume = resume
      @context = context.to_sym
      @view_context = view_context
    end

    attr_reader :context

    def actions
      @actions ||= context == :show ? show_actions : finalize_actions
    end

    private
      attr_reader :resume, :view_context

      def show_actions
        if resume.pdf_export.attached?
          [
            {
              label: I18n.t("resumes.export_actions_state.actions.download_pdf"),
              path: view_context.download_resume_path(resume),
              style: :secondary,
              options: { data: { turbo_frame: "_top" } }
            },
            {
              label: I18n.t("resumes.export_actions_state.actions.download_text"),
              path: view_context.download_text_resume_path(resume),
              style: :secondary,
              options: { data: { turbo_frame: "_top" } }
            }
          ]
        else
          [
            {
              label: I18n.t("resumes.export_actions_state.actions.export_pdf"),
              path: view_context.export_resume_path(resume),
              method: :post,
              style: :secondary
            },
            {
              label: I18n.t("resumes.export_actions_state.actions.download_text"),
              path: view_context.download_text_resume_path(resume),
              style: :secondary,
              options: { data: { turbo_frame: "_top" } }
            }
          ]
        end
      end

      def finalize_actions
        actions = [
          {
            label: I18n.t("resumes.export_actions_state.actions.export_pdf"),
            path: view_context.export_resume_path(resume, **view_context.resume_builder_step_params("finalize")),
            method: :post,
            style: :secondary
          }
        ]

        if resume.pdf_export.attached?
          actions << {
            label: I18n.t("resumes.export_actions_state.actions.download_pdf"),
            path: view_context.download_resume_path(resume),
            style: :primary,
            options: { data: { turbo_frame: "_top" } }
          }
        end

        actions << {
          label: I18n.t("resumes.export_actions_state.actions.download_text"),
          path: view_context.download_text_resume_path(resume),
          style: :secondary,
          options: { data: { turbo_frame: "_top" } }
        }

        actions
      end
  end
end
