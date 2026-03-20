module Resumes
  class ExportStatusState
    def initialize(resume:, context:, view_context:)
      @resume = resume
      @context = context.to_sym
      @view_context = view_context
    end

    attr_reader :context

    def widget_attributes
      {
        eyebrow: "Export status",
        title: view_context.resume_export_status_label(resume),
        description: view_context.resume_export_status_message(resume),
        tone: widget_tone,
        padding: :sm,
        badge: badge_label,
        badge_classes: "rounded-full px-3 py-1 text-xs font-medium #{view_context.resume_export_status_badge_classes(resume, context: context)}",
        title_size: :xl
      }
    end

    def download_available?
      resume.pdf_export.attached? && context != :show
    end

    def download_path
      view_context.download_resume_path(resume)
    end

    def download_button_style
      context == :editor ? :hero_secondary : :secondary
    end

    private
      attr_reader :resume, :view_context

      def widget_tone
        return :dark if context == :editor
        return :default if context == :show

        :subtle
      end

      def badge_label
        resume.export_state.presence&.humanize || "Draft"
      end
  end
end
