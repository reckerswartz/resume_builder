module ResumeBuilder
  class PreviewState
    def initialize(resume:, builder_state:, view_context:)
      @resume = resume
      @builder_state = builder_state
      @view_context = view_context
    end

    def panel_attributes
      {
        eyebrow: "Live preview",
        title: "Check the page as you edit",
        description: "Use this rail to compare changes without leaving the builder.",
        padding: :sm,
        density: :compact
      }
    end

    def badges
      @badges ||= [
        { label: resume.template.name, tone: :neutral },
        { label: "#{builder_state.completion_percentage}% complete", tone: :neutral }
      ]
    end

    def sync_card_attributes
      {
        eyebrow: "Save status",
        title: "Autosave on",
        description: "Field changes save in place while the live preview refreshes.",
        padding: :sm
      }
    end

    def preview_page_action
      {
        label: "Open preview",
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
