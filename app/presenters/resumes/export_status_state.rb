module Resumes
  class ExportStatusState
    def initialize(resume:, context:, view_context:)
      @resume = resume
      @context = context.to_sym
      @view_context = view_context
    end

    attr_reader :context

    def status_label
      I18n.t("resumes.helper.export_status.labels.#{export_state_key}")
    end

    def status_message
      key = export_state_key
      return I18n.t("resumes.helper.export_status.messages.#{key}") unless %w[queued running failed].include?(resume.export_state)

      sub_key = resume.pdf_export.attached? ? "with_download" : "without_download"
      I18n.t("resumes.helper.export_status.messages.#{key}.#{sub_key}")
    end

    def status_badge_classes
      dark = context == :editor

      case resume.export_state
      when "ready"
        dark ? "border border-emerald-300/30 bg-emerald-300/15 text-emerald-100" : "border border-emerald-200 bg-emerald-50 text-emerald-700"
      when "failed"
        dark ? "border border-rose-300/30 bg-rose-300/15 text-rose-100" : "border border-rose-200 bg-rose-50 text-rose-700"
      when "running"
        dark ? "border border-amber-300/30 bg-amber-300/15 text-amber-100" : "border border-amber-200 bg-amber-50 text-amber-700"
      when "queued"
        dark ? "border border-sky-300/30 bg-sky-300/15 text-sky-100" : "border border-sky-200 bg-sky-50 text-sky-700"
      else
        dark ? "border border-white/15 bg-white/10 text-white/80" : "border border-canvas-200/80 bg-canvas-50/88 text-ink-700"
      end
    end

    def widget_attributes
      {
        eyebrow: I18n.t("resumes.export_status_state.widget.eyebrow"),
        title: status_label,
        description: status_message,
        tone: widget_tone,
        padding: :sm,
        badge: badge_label,
        badge_classes: "rounded-full px-3 py-1 text-xs font-medium #{status_badge_classes}",
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

      def export_state_key
        %w[queued running failed ready].include?(resume.export_state) ? resume.export_state : "draft_only"
      end

      def widget_tone
        return :dark if context == :editor
        return :default if context == :show

        :subtle
      end

      def badge_label
        I18n.t("resumes.export_states.#{resume.export_state}", default: I18n.t("resumes.export_status_state.widget.draft_badge"))
      end
  end
end
