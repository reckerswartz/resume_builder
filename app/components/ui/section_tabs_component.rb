module Ui
  class SectionTabsComponent < ApplicationComponent
    BOOLEAN_TYPE = ActiveModel::Type::Boolean.new

    attr_reader :label

    def initialize(items:, label: "Section tabs")
      @items = normalize_items(items)
      @label = label
    end

    def items
      @items
    end

    def grid_classes
      mobile_base = "builder-step-tabs"

      case [ items.size, 7 ].min
      when 1
        "#{mobile_base} sm:grid-cols-1"
      when 2
        "#{mobile_base} sm:grid-cols-2"
      when 3
        "#{mobile_base} sm:grid-cols-2 xl:grid-cols-3"
      when 4
        "#{mobile_base} sm:grid-cols-2 xl:grid-cols-4"
      when 5
        "#{mobile_base} sm:grid-cols-2 xl:grid-cols-5"
      when 6
        "#{mobile_base} sm:grid-cols-2 xl:grid-cols-6"
      else
        "#{mobile_base} sm:grid-cols-2 xl:grid-cols-7"
      end
    end

    def link_options(item)
      item.fetch(:html_options, {}).to_h.deep_dup.tap do |options|
        options[:class] = [ options[:class], link_classes(item) ].compact.join(" ")
        options[:aria] = options.fetch(:aria, {}).to_h.merge(current?(item) ? { current: "page" } : {})
      end
    end

    def link_classes(item)
      base = "builder-step-tab group rounded-[1.5rem] border shadow-sm transition"

      case state(item)
      when :current
        "#{base} border-slate-900 bg-slate-900 text-white shadow-slate-900/15"
      when :completed
        "#{base} border-emerald-200 bg-emerald-50 text-emerald-900 shadow-emerald-200/60"
      else
        "#{base} border-slate-200 bg-white text-slate-600 shadow-slate-200/80 hover:border-slate-300 hover:text-slate-900"
      end
    end

    def badge_classes(item)
      case state(item)
      when :current
        "builder-step-tab-badge flex items-center justify-center rounded-2xl bg-white/10 text-sm font-semibold text-white"
      when :completed
        "builder-step-tab-badge flex items-center justify-center rounded-2xl bg-white text-sm font-semibold text-emerald-700"
      else
        "builder-step-tab-badge flex items-center justify-center rounded-2xl bg-slate-100 text-sm font-semibold text-slate-500"
      end
    end

    def status_classes(item)
      case state(item)
      when :current
        "text-white/70"
      when :completed
        "text-emerald-600"
      else
        "text-slate-400"
      end
    end

    private
      def normalize_items(items)
        Array(items).map do |item|
          item.to_h.transform_keys(&:to_sym)
        end
      end

      def current?(item)
        BOOLEAN_TYPE.cast(item[:current])
      end

      def completed?(item)
        BOOLEAN_TYPE.cast(item[:completed])
      end

      def state(item)
        return :current if current?(item)
        return :completed if completed?(item)

        item.fetch(:state, :pending).to_sym
      end
  end
end
