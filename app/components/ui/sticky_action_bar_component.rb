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
        "sticky sticky-action-bar-compact bottom-3 z-10 rounded-[1.25rem] border border-slate-200 bg-white/95 px-4 py-3 shadow-lg shadow-slate-900/5 backdrop-blur-sm sm:px-5"
      else
        "sticky bottom-4 z-10 rounded-[1.5rem] border border-slate-200 bg-white/95 p-4 shadow-lg shadow-slate-900/5 backdrop-blur-sm"
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
      "text-sm font-semibold tracking-tight text-slate-900"
    end

    def description_classes
      if compact?
        "mt-1 text-sm leading-5 text-slate-500"
      else
        "mt-1 text-sm text-slate-500"
      end
    end

    def content_classes
      "flex flex-wrap gap-2 sm:justify-end"
    end
  end
end
