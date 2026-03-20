module Ui
  class SectionLinkCardComponent < ApplicationComponent
    attr_reader :label, :caption, :path

    def initialize(label:, path:, caption: nil)
      @label = label
      @caption = caption
      @path = path
    end

    def wrapper_classes
      "block rounded-[1.25rem] border border-canvas-200/80 bg-canvas-50/80 px-4 py-4 transition hover:border-mist-300 hover:bg-canvas-50"
    end
  end
end
