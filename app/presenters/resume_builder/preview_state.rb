module ResumeBuilder
  class PreviewState
    def initialize(resume:, builder_state:, view_context:)
      @resume = resume
      @builder_state = builder_state
      @view_context = view_context
    end

    def panel_attributes
      {
        eyebrow: I18n.t("resume_builder.preview_state.panel.eyebrow"),
        title: I18n.t("resume_builder.preview_state.panel.title"),
        description: I18n.t("resume_builder.preview_state.panel.description"),
        padding: :sm,
        density: :compact
      }
    end

    def badges
      @badges ||= [
        { label: resume.template.name, tone: :neutral },
        { label: I18n.t("resume_builder.preview_state.panel.completion_badge", percent: builder_state.completion_percentage), tone: :neutral }
      ]
    end

    def sync_card_attributes
      {
        eyebrow: I18n.t("resume_builder.preview_state.sync_card.eyebrow"),
        title: I18n.t("resume_builder.preview_state.sync_card.title"),
        description: I18n.t("resume_builder.preview_state.sync_card.description"),
        padding: :sm
      }
    end

    def preview_page_action
      {
        label: I18n.t("resume_builder.preview_state.actions.open_preview"),
        path: view_context.resume_path(resume, step: current_step_key),
        style: :secondary,
        size: :sm,
        options: { data: { turbo_frame: "_top" } }
      }
    end

    def export_status_state
      @export_status_state ||= view_context.resume_export_status_state(resume, context: :preview)
    end

    private
      attr_reader :builder_state, :resume, :view_context

      def current_step_key
        builder_state.current_step.fetch(:key)
      end
  end
end
