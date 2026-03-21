module Ui
  class CodeBlockComponent < ApplicationComponent
    attr_reader :title, :body, :description, :tone, :padding, :wrap

    def initialize(title:, body:, description: nil, tone: :default, padding: :md, wrap: false)
      @title = title
      @body = body
      @description = description
      @tone = tone
      @padding = padding
      @wrap = wrap
    end

    def wrapper_classes
      [ helpers.ui_surface_classes(tone:, padding:), "min-w-0" ].join(" ")
    end

    def title_classes
      [ "text-xl font-semibold tracking-tight", tone.to_sym == :danger ? "text-rose-900" : "text-ink-950" ].join(" ")
    end

    def description_classes
      [ "mt-2 text-sm", tone.to_sym == :danger ? "text-rose-700" : "text-ink-700/80" ].join(" ")
    end

    def block_classes
      [
        "mt-4 max-w-full overflow-x-auto rounded-2xl bg-ink-950 px-4 py-4 text-sm text-canvas-50",
        wrap ? "whitespace-pre-wrap break-words" : "whitespace-pre"
      ].join(" ")
    end
  end
end
