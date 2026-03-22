module Resumes
  class ShowState
    def initialize(resume:, builder_state:, view_context:)
      @resume = resume
      @builder_state = builder_state
      @view_context = view_context
    end

    def page_header_attributes
      {
        eyebrow: I18n.t("resumes.show_state.page_header.eyebrow"),
        title: resume.title,
        description: I18n.t("resumes.show_state.page_header.description"),
        badges: badges,
        actions: actions,
        density: :compact
      }
    end

    def badges
      @badges ||= [
        { label: resume.template.name, tone: :neutral },
        { label: I18n.t("resumes.show_state.page_header.completion_badge", percent: builder_state.completion_percentage), tone: :neutral },
        { label: export_state_label, tone: export_badge_tone }
      ]
    end

    def actions
      @actions ||= [
        { label: I18n.t("resumes.show_state.page_header.back_to_workspace"), path: view_context.resumes_path, style: :secondary, size: :sm },
        { label: I18n.t("resumes.show_state.page_header.edit_resume"), path: view_context.edit_resume_path(resume, step: current_step_key), style: :primary, size: :sm }
      ]
    end

    def artifact_badges
      @artifact_badges ||= [
        { label: resume.template.name, tone: :neutral }
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

      def export_state_label
        I18n.t("resumes.export_states.#{resume.export_state}", default: resume.export_state.to_s.humanize.presence || I18n.t("resumes.export_states.draft"))
      end

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
