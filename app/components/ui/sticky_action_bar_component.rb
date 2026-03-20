module Ui
  class StickyActionBarComponent < ApplicationComponent
    attr_reader :title, :description, :density

    def initialize(title:, description: nil, density: :default)
      @title = title
      @description = description
      @density = density.to_sym
    end

    def compact?
      density == :compact
    end

    def wrapper_classes
      if compact?
        "sticky sticky-action-bar-compact bottom-3 z-10 rounded-[1.25rem] border border-canvas-200/80 bg-canvas-50/96 px-4 py-3 shadow-[0_18px_40px_rgba(15,23,42,0.08)] backdrop-blur-sm sm:px-5"
      else
        "sticky bottom-4 z-10 rounded-[1.5rem] border border-canvas-200/80 bg-canvas-50/96 p-4 shadow-[0_18px_40px_rgba(15,23,42,0.08)] backdrop-blur-sm"
      end
    end

    def layout_classes
      if compact?
        "flex flex-col gap-3 sm:flex-row sm:items-center sm:justify-between"
      else
        "flex flex-col gap-4 sm:flex-row sm:items-center sm:justify-between"
      end
    end

    def title_classes
      "text-sm font-semibold tracking-tight text-ink-950"
    end

    def description_classes
      if compact?
        "mt-1 text-sm leading-6 text-ink-700/80"
      else
        "mt-1 text-sm leading-6 text-ink-700/80"
      end
    end

    def content_classes
      "flex flex-wrap gap-2 sm:justify-end"
    end
  end
end
