module Ui
  class PageHeaderComponent < ApplicationComponent
    attr_reader :eyebrow, :title, :description, :density

    def initialize(eyebrow:, title:, description: nil, badges: [], actions: [], density: :default)
      @eyebrow = eyebrow
      @title = title
      @description = description
      @density = density.to_sym
      @badges = normalize_items(badges)
      @actions = normalize_items(actions)
    end

    def badges
      @badges
    end

    def actions
      @actions
    end

    def compact?
      density == :compact
    end

    def wrapper_classes
      if compact?
        "atelier-panel page-header-compact px-5 py-4 sm:px-6"
      else
        "atelier-panel px-6 py-5 sm:px-7"
      end
    end

    def divider_classes
      if compact?
        "absolute inset-x-5 top-0 h-px atelier-rule-ink opacity-70 sm:inset-x-6"
      else
        "absolute inset-x-6 top-0 h-px atelier-rule-ink opacity-70"
      end
    end

    def layout_classes
      if compact?
        "relative flex flex-col gap-3 sm:flex-row sm:items-end sm:justify-between"
      else
        "relative flex flex-col gap-4 sm:flex-row sm:items-end sm:justify-between"
      end
    end

    def eyebrow_classes
      if compact?
        "text-[0.68rem] font-semibold uppercase tracking-[0.2em] text-ink-700/70"
      else
        "text-[0.72rem] font-semibold uppercase tracking-[0.2em] text-ink-700/70"
      end
    end

    def title_classes
      if compact?
        "mt-2 font-serif text-2xl font-semibold tracking-[-0.03em] text-ink-950 sm:text-3xl"
      else
        "mt-3 font-serif text-3xl font-semibold tracking-[-0.03em] text-ink-950 sm:text-4xl"
      end
    end

    def description_classes
      if compact?
        "mt-2 max-w-3xl text-sm leading-6 text-ink-700/80"
      else
        "mt-3 max-w-3xl text-sm leading-6 text-ink-700/80"
      end
    end

    def badges_classes
      if compact?
        "mt-3 flex flex-wrap gap-2"
      else
        "mt-4 flex flex-wrap gap-2"
      end
    end

    def actions_classes
      "flex flex-wrap gap-2"
    end

    def default_action_size
      compact? ? :sm : :md
    end

    private
      def normalize_items(items)
        Array(items).map do |item|
          item.to_h.transform_keys(&:to_sym)
        end
      end
  end
end
