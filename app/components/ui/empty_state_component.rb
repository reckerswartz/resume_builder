module Ui
  class EmptyStateComponent < ApplicationComponent
    attr_reader :title, :description, :action_label, :action_path, :action_style, :padding, :tone, :align, :tag_name, :title_size

    def initialize(title: nil, description: nil, action_label: nil, action_path: nil, action_style: :primary, padding: :md, tone: :default, align: :center, tag: :div, title_size: :md)
      @title = title
      @description = description
      @action_label = action_label
      @action_path = action_path
      @action_style = action_style
      @padding = padding
      @tone = tone
      @align = align
      @tag_name = tag
      @title_size = title_size
    end

    def wrapper_classes
      [ "rounded-[2rem] border border-dashed shadow-[0_18px_44px_rgba(15,23,42,0.08)] backdrop-blur-sm", padding_classes, tone_classes, alignment_classes ].reject(&:blank?).join(" ")
    end

    def action?
      action_label.present? && action_path.present?
    end

    def content_classes
      [ header? ? "mt-4" : nil, centered? ? "flex justify-center" : nil ].compact.join(" ")
    end

    def title_classes
      [ title_size_classes, "font-serif font-semibold tracking-[-0.03em] text-ink-950" ].join(" ")
    end

    def description_classes
      [ title.present? ? "mt-2" : nil, "text-sm leading-6 text-ink-700/80" ].compact.join(" ")
    end

    def action_wrapper_classes
      [ "mt-5", centered? ? "flex justify-center" : nil ].compact.join(" ")
    end

    def action_classes
      helpers.ui_button_classes(action_style)
    end

    def header?
      title.present? || description.present? || action?
    end

    private
      def centered?
        align.to_sym != :left
      end

      def alignment_classes
        centered? ? "text-center" : nil
      end

      def padding_classes
        case padding.to_sym
        when :sm
          "px-4 py-4"
        when :lg
          "px-6 py-10"
        else
          "px-6 py-8"
        end
      end

      def tone_classes
        case tone.to_sym
        when :subtle
          "border-mist-200/80 bg-canvas-100/88"
        else
          "border-canvas-200/80 bg-canvas-50/92"
        end
      end

      def title_size_classes
        case title_size.to_sym
        when :sm
          "text-base"
        when :lg
          "text-xl"
        else
          "text-lg"
        end
      end
  end
end
