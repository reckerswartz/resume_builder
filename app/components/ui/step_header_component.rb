module Ui
  class StepHeaderComponent < ApplicationComponent
    attr_reader :title, :description, :aside_classes

    def initialize(title:, description: nil, aside_classes: nil)
      @title = title
      @description = description
      @aside_classes = aside_classes
    end

    def resolved_aside_classes
      aside_classes.presence || "w-full lg:max-w-sm"
    end
  end
end
