module Ui
  class MetricCardComponent < ApplicationComponent
    attr_reader :label, :value, :description, :tone

    def initialize(label:, value:, description:, tone: :default)
      @label = label
      @value = value
      @description = description
      @tone = tone
    end

    def hero?
      tone.to_sym == :hero
    end
  end
end
