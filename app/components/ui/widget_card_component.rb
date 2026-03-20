module Ui
  class WidgetCardComponent < ApplicationComponent
    attr_reader :badge, :badge_classes, :eyebrow, :title, :description, :tone, :padding, :title_size

    def initialize(eyebrow:, title:, description: nil, tone: :subtle, padding: :md, badge: nil, badge_classes: nil, title_size: :lg)
      @badge = badge
      @badge_classes = badge_classes
      @eyebrow = eyebrow
      @title = title
      @description = description
      @tone = tone
      @padding = padding
      @title_size = title_size
    end

    def wrapper_classes
      [ "relative overflow-hidden rounded-[1.5rem] border", tone_classes, padding_classes ].join(" ")
    end

    def eyebrow_classes
      dark? ? "text-white/60" : "text-ink-700/70"
    end

    def title_classes
      [ title_size_classes, "font-semibold tracking-tight", dark? ? "text-white" : "text-ink-950" ].join(" ")
    end

    def description_classes
      dark? ? "text-white/70" : "text-ink-700/80"
    end

    def body_spacing_classes
      description.present? ? "mt-4" : "mt-3"
    end

    def resolved_badge_classes
      badge_classes.presence || helpers.ui_badge_classes(dark? ? :hero : tone.to_sym == :success ? :success : :neutral)
    end

    private
      def dark?
        tone.to_sym == :dark
      end

      def title_size_classes
        case title_size.to_sym
        when :xl
          "text-2xl"
        when :base
          "text-base"
        else
          "text-lg"
        end
      end

      def padding_classes
        case padding.to_sym
        when :sm
          "p-4"
        when :lg
          "p-6"
        else
          "p-5"
        end
      end

      def tone_classes
        case tone.to_sym
        when :default
          "border-canvas-200/80 bg-canvas-50/92 text-ink-950 shadow-[0_18px_40px_rgba(15,23,42,0.08)] backdrop-blur-sm"
        when :dark
          "border-white/10 bg-ink-950/90 text-white backdrop-blur-sm"
        when :success
          "border-emerald-200/80 bg-canvas-50/95 text-emerald-900 shadow-[0_18px_40px_rgba(16,185,129,0.08)] backdrop-blur-sm"
        else
          "border-mist-200/80 bg-canvas-100/88 text-ink-950 shadow-[0_18px_40px_rgba(15,23,42,0.06)] backdrop-blur-sm"
        end
      end
  end
end
