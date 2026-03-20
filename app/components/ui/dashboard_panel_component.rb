module Ui
  class DashboardPanelComponent < ApplicationComponent
    attr_reader :eyebrow, :title, :description, :action_label, :action_path, :action_style, :padding, :tone, :density

    def initialize(title:, eyebrow: nil, description: nil, action_label: nil, action_path: nil, action_style: :ghost, padding: :md, tone: :default, density: :default)
      @eyebrow = eyebrow
      @title = title
      @description = description
      @action_label = action_label
      @action_path = action_path
      @action_style = action_style
      @padding = padding
      @tone = tone
      @density = density.to_sym
    end

    def wrapper_classes
      extra_classes = [ "overflow-hidden", ("dashboard-panel-compact" if compact?) ].compact.join(" ")

      helpers.ui_surface_classes(tone:, padding: resolved_padding, extra: extra_classes)
    end

    def action?
      action_label.present? && action_path.present?
    end

    def header?
      eyebrow.present? || title.present? || description.present? || action?
    end

    def dark_surface?
      tone.to_sym == :brand || tone.to_sym == :dark
    end

    def compact?
      density == :compact
    end

    def header_classes
      [ "relative flex items-start justify-between border-b", compact? ? "gap-3 pb-4" : "gap-4 pb-5", header_border_classes ].join(" ")
    end

    def eyebrow_classes
      [ compact? ? "text-[0.68rem]" : "text-xs", "font-semibold uppercase tracking-[0.24em]", (dark_surface? ? "text-white/60" : "text-ink-700/70") ].join(" ")
    end

    def title_classes
      [ compact? ? "text-lg" : "text-xl", "font-semibold tracking-tight", (dark_surface? ? "text-white" : "text-ink-950") ].join(" ")
    end

    def description_classes
      [ "text-sm", compact? ? "mt-1.5 leading-6" : "mt-2", (dark_surface? ? "text-white/72" : "text-ink-700/80") ].join(" ")
    end

    def content_classes
      header? ? "relative #{compact? ? 'mt-4' : 'mt-5'}" : "relative"
    end

    def action_classes
      helpers.ui_button_classes(resolved_action_style, size: :sm)
    end

    private
      def resolved_padding
        return :sm if compact? && padding.to_sym == :md

        padding
      end

      def header_border_classes
        dark_surface? ? "border-white/10" : "border-canvas-200/80"
      end

      def resolved_action_style
        return :hero_secondary if dark_surface? && action_style.to_sym == :ghost

        action_style
      end
  end
end
