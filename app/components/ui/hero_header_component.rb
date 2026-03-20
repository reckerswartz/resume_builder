module Ui
  class HeroHeaderComponent < ApplicationComponent
    attr_reader :eyebrow, :title, :description, :avatar_text, :density

    def initialize(eyebrow:, title:, description: nil, avatar_text: nil, badges: [], actions: [], metrics: [], density: :default)
      @eyebrow = eyebrow
      @title = title
      @description = description
      @avatar_text = avatar_text
      @density = density.to_sym
      @badges = normalize_items(badges)
      @actions = normalize_items(actions)
      @metrics = normalize_items(metrics)
    end

    def badges
      @badges
    end

    def actions
      @actions
    end

    def metrics
      @metrics
    end

    def compact?
      density == :compact
    end

    def section_classes
      [ "atelier-hero", ("atelier-hero-compact" if compact?) ].compact.join(" ")
    end

    def inner_classes
      if compact?
        "relative px-5 py-5 text-white sm:px-6 lg:px-8"
      else
        "relative px-6 py-6 text-white sm:px-8 lg:px-10"
      end
    end

    def primary_glow_classes
      if compact?
        "absolute -left-12 top-6 h-32 w-32 rounded-full atelier-glow opacity-70"
      else
        "absolute -left-16 top-8 h-44 w-44 rounded-full atelier-glow opacity-80"
      end
    end

    def secondary_glow_classes
      if compact?
        "absolute right-8 top-8 h-20 w-20 rounded-full atelier-bloom opacity-25"
      else
        "absolute right-10 top-10 h-24 w-24 rounded-full atelier-bloom opacity-30"
      end
    end

    def divider_classes
      if compact?
        "absolute inset-x-6 bottom-0 h-px atelier-rule opacity-50"
      else
        "absolute inset-x-8 bottom-0 h-px atelier-rule opacity-55"
      end
    end

    def dot_pattern_classes
      if compact?
        "absolute left-6 top-20 h-20 w-24 rounded-full atelier-halftone opacity-[0.08]"
      else
        "absolute left-8 top-24 h-24 w-32 rounded-full atelier-halftone opacity-10"
      end
    end

    def layout_classes
      if compact?
        "relative flex flex-col gap-5 xl:flex-row xl:items-start xl:justify-between"
      else
        "relative flex flex-col gap-6 xl:flex-row xl:items-start xl:justify-between"
      end
    end

    def identity_classes
      if compact?
        "flex flex-col gap-3 sm:flex-row sm:items-start"
      else
        "flex flex-col gap-4 sm:flex-row sm:items-start"
      end
    end

    def avatar_classes
      if compact?
        "flex h-14 w-14 items-center justify-center rounded-[1.5rem] border border-white/10 bg-white/8 text-base font-semibold tracking-[0.2em] text-white shadow-inner shadow-white/10"
      else
        "flex h-16 w-16 items-center justify-center rounded-[1.75rem] border border-white/10 bg-white/8 text-lg font-semibold tracking-[0.2em] text-white shadow-inner shadow-white/10"
      end
    end

    def eyebrow_classes
      if compact?
        "text-[0.72rem] font-semibold uppercase tracking-[0.24em] text-white/55"
      else
        "text-sm font-semibold uppercase tracking-[0.24em] text-white/55"
      end
    end

    def title_classes
      if compact?
        "mt-3 max-w-4xl font-serif text-3xl font-semibold tracking-[-0.03em] text-white sm:text-4xl"
      else
        "mt-3 max-w-4xl font-serif text-4xl font-semibold tracking-[-0.03em] text-white sm:text-5xl"
      end
    end

    def description_classes
      if compact?
        "mt-3 max-w-3xl text-sm leading-6 text-white/72"
      else
        "mt-3 max-w-3xl text-sm leading-6 text-white/72 sm:text-base"
      end
    end

    def badges_classes
      if compact?
        "mt-4 flex flex-wrap gap-2 text-xs font-medium text-white/80"
      else
        "mt-5 flex flex-wrap gap-2 text-xs font-medium text-white/80"
      end
    end

    def actions_classes
      if compact?
        "flex max-w-xl flex-wrap gap-2 xl:justify-end"
      else
        "flex max-w-sm flex-wrap gap-3 xl:justify-end"
      end
    end

    def metrics_grid_classes
      base = "grid gap-3"

      case [ metrics.size, 4 ].min
      when 1
        base
      when 2
        "#{base} sm:grid-cols-2"
      when 3
        "#{base} sm:grid-cols-2 xl:grid-cols-3"
      else
        "#{base} sm:grid-cols-2 xl:grid-cols-4"
      end
    end

    def metrics_wrapper_classes
      spacing_classes = if compact?
        "relative mt-6 border-t border-white/10 pt-5"
      else
        "relative mt-8 border-t border-white/10 pt-6"
      end

      [ spacing_classes, metrics_grid_classes ].join(" ")
    end

    private
      def normalize_items(items)
        Array(items).map do |item|
          item.to_h.transform_keys(&:to_sym)
        end
      end
  end
end
