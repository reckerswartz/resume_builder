module Ui
  class ReportRowComponent < ApplicationComponent
    attr_reader :title, :subtitle, :path

    def initialize(title:, subtitle: nil, badge: nil, badge_classes: nil, badges: [], path: nil)
      @title = title
      @subtitle = subtitle
      @path = path
      @badges = normalize_badges(badge:, badge_classes:, badges:)
    end

    def badges
      @badges
    end

    def linked?
      path.present?
    end

    def wrapper_classes
      base = "flex items-center justify-between gap-4 rounded-2xl border border-slate-200 px-4 py-4"
      state_classes = linked? ? "transition hover:border-slate-300 hover:bg-slate-50" : "bg-white"

      [ base, state_classes ].join(" ")
    end

    private
      def normalize_badges(badge:, badge_classes:, badges:)
        items = Array(badges).map do |item|
          item.to_h.symbolize_keys
        end

        if badge.present?
          items.unshift(label: badge, classes: badge_classes)
        end

        items
      end
  end
end
