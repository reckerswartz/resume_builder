module ResumeBuilder
  class WorkspaceState
    def initialize(resume:, builder_state:, view_context:)
      @resume = resume
      @builder_state = builder_state
      @view_context = view_context
    end

    def page_header_attributes
      {
        eyebrow: "Guided builder",
        title: resume.title,
        description: description,
        badges: badges,
        actions: actions,
        density: :compact
      }
    end

    def description
      resume.headline.presence || "Work through each step for #{primary_identity} while the preview stays visible."
    end

    def badges
      @badges ||= [
        { label: resume.template.name, tone: :neutral },
        { label: "#{builder_state.completed_steps_count}/#{builder_state.total_steps} steps ready", tone: :neutral }
      ]
    end

    def actions
      @actions ||= [
        { label: "Back to workspace", path: view_context.resumes_path, style: :secondary },
        { label: "Open preview", path: view_context.resume_path(resume, step: current_step_key), style: :primary }
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
