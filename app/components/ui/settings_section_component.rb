module Ui
  class SettingsSectionComponent < ApplicationComponent
    attr_reader :anchor, :eyebrow, :title, :description, :padding, :badges

    def initialize(title:, anchor: nil, eyebrow: nil, description: nil, badges: [], padding: :md)
      @anchor = anchor
      @eyebrow = eyebrow
      @title = title
      @description = description
      @badges = normalize_items(badges)
      @padding = padding
    end

    def wrapper_classes
      helpers.ui_surface_classes(tone: :default, padding:, extra: "overflow-hidden")
    end

    def content_classes
      "mt-5"
    end

    private
      def normalize_items(items)
        Array(items).map do |item|
          item.to_h.transform_keys(&:to_sym)
        end
      end
  end
end
