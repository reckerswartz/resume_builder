module Resumes
  class ShowState
    def initialize(resume:, builder_state:, view_context:)
      @resume = resume
      @builder_state = builder_state
      @view_context = view_context
    end

    def page_header_attributes
      {
        eyebrow: "Preview",
        title: resume.title,
        description: "Review the latest preview, check export status, and decide whether to download or keep editing.",
        badges: badges,
        actions: actions,
        density: :compact
      }
    end

    def badges
      @badges ||= [
        { label: resume.template.name, tone: :neutral },
        { label: "#{builder_state.completion_percentage}% complete", tone: :neutral },
        { label: resume.export_state.humanize, tone: export_badge_tone }
      ]
    end

    def actions
      @actions ||= [
        { label: "Back to workspace", path: view_context.resumes_path, style: :secondary, size: :sm },
        { label: "Edit resume", path: view_context.edit_resume_path(resume, step: current_step_key), style: :primary, size: :sm }
      ]
    end

    def artifact_badges
      @artifact_badges ||= [
        { label: resume.template.name, tone: :neutral },
        { label: resume.export_state.humanize, tone: export_badge_tone }
      ]
    end

    def export_actions_state
      @export_actions_state ||= view_context.resume_export_actions_state(resume, context: :show)
    end

    def export_status_state
      @export_status_state ||= view_context.resume_export_status_state(resume, context: :show)
    end

    def preview_surface_attributes
      {
        tag: :div,
        padding: :none,
        extra_classes: "p-4 sm:p-6"
      }
    end

    private
      attr_reader :builder_state, :resume, :view_context

      def current_step_key
        builder_state.current_step.fetch(:key)
      end

      def export_badge_tone
        case resume.export_state
        when "ready"
          :success
        when "queued", "running"
          :info
        when "failed"
          :danger
        else
          :neutral
        end
      end
  end
end
