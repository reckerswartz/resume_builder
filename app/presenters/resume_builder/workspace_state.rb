module ResumeBuilder
  class WorkspaceState
    def initialize(resume:, builder_state:, view_context:)
      @resume = resume
      @builder_state = builder_state
      @view_context = view_context
    end

    def page_header_attributes
      {
        eyebrow: I18n.t("resume_builder.workspace_state.page_header.eyebrow"),
        title: resume.title,
        description: description,
        badges: badges,
        actions: actions,
        density: :compact
      }
    end

    def description
      resume.headline.presence || I18n.t("resume_builder.workspace_state.page_header.description", identity: primary_identity)
    end

    def badges
      @badges ||= [
        { label: resume.template.name, tone: :neutral },
        { label: I18n.t("resume_builder.workspace_state.page_header.steps_ready", completed: builder_state.completed_steps_count, total: builder_state.total_steps), tone: :neutral }
      ]
    end

    def actions
      @actions ||= [
        { label: I18n.t("resume_builder.workspace_state.page_header.back_to_workspace"), path: view_context.resumes_path, style: :secondary },
        { label: I18n.t("resume_builder.workspace_state.page_header.open_preview"), path: view_context.resume_path(resume, step: current_step_key), style: :primary }
      ]
    end

    def primary_identity
      @primary_identity ||= builder_state.primary_identity
    end

    private
      attr_reader :builder_state, :resume, :view_context

      def current_step_key
        builder_state.current_step.fetch(:key)
      end
  end
end
