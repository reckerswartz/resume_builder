module Ui
  class GlyphComponent < ApplicationComponent
    ICONS = {
      spark: [
        { d: "M12 3.5L13.8 7.7L18 9.5L13.8 11.3L12 15.5L10.2 11.3L6 9.5L10.2 7.7L12 3.5Z" },
        { d: "M18.5 4L19.15 5.35L20.5 6L19.15 6.65L18.5 8L17.85 6.65L16.5 6L17.85 5.35L18.5 4Z" },
        { d: "M5.5 16L6.15 17.35L7.5 18L6.15 18.65L5.5 20L4.85 18.65L3.5 18L4.85 17.35L5.5 16Z" }
      ],
      layers: [
        { d: "M12 4L20 8.5L12 13L4 8.5L12 4Z" },
        { d: "M4 12.5L12 17L20 12.5" },
        { d: "M4 16.5L12 21L20 16.5" }
      ],
      preview: [
        { d: "M3.5 12S6.5 6.5 12 6.5S20.5 12 20.5 12S17.5 17.5 12 17.5S3.5 12 3.5 12Z" },
        { d: "M12 14.5A2.5 2.5 0 1 0 12 9.5A2.5 2.5 0 0 0 12 14.5Z" }
      ],
      shield: [
        { d: "M12 3L18.5 5.5V10.7C18.5 15.1 15.9 19.1 12 21C8.1 19.1 5.5 15.1 5.5 10.7V5.5L12 3Z" },
        { d: "M9.5 11.5L11.3 13.3L14.8 9.8" }
      ],
      swatches: [
        { d: "M7 4.5H17A2.5 2.5 0 0 1 19.5 7V17A2.5 2.5 0 0 1 17 19.5H7A2.5 2.5 0 0 1 4.5 17V7A2.5 2.5 0 0 1 7 4.5Z" },
        { d: "M8.5 8.5H15.5" },
        { d: "M8.5 12H15.5" },
        { d: "M8.5 15.5H12.5" }
      ]
    }.freeze

    attr_reader :name, :size, :tone

    def initialize(name:, size: :md, tone: :default)
      @name = name.to_sym
      @size = size.to_sym
      @tone = tone.to_sym
    end

    def call
      helpers.content_tag(:span, svg_icon, class: wrapper_classes, aria: { hidden: true })
    end

    private
      def svg_icon
        helpers.tag.svg(
          path_markup,
          xmlns: "http://www.w3.org/2000/svg",
          viewBox: "0 0 24 24",
          fill: "none",
          stroke: "currentColor",
          stroke_width: 1.75,
          stroke_linecap: "round",
          stroke_linejoin: "round",
          class: svg_classes,
          aria: { hidden: true }
        )
      end

      def path_markup
        helpers.safe_join(
          ICONS.fetch(name).map do |attributes|
            helpers.tag.path(**attributes)
          end
        )
      end

      def wrapper_classes
        [ "inline-flex shrink-0 items-center justify-center", size_classes, tone_classes ].join(" ")
      end

      def size_classes
        case size
        when :xs
          "h-4 w-4"
        when :sm
          "h-9 w-9"
        when :lg
          "h-12 w-12 rounded-[1.2rem]"
        else
          "h-10 w-10"
        end
      end

      def tone_classes
        case tone
        when :minimal
          "text-current"
        when :soft
          "rounded-[1rem] border border-mist-200/80 bg-canvas-100/88 text-ink-900 shadow-[0_12px_28px_rgba(15,23,42,0.06)]"
        when :dark
          "rounded-[1rem] border border-white/10 bg-ink-950 text-white shadow-[0_12px_28px_rgba(2,6,23,0.2)]"
        when :hero
          "rounded-[1rem] border border-white/12 bg-white/8 text-white shadow-inner shadow-white/10"
        else
          "rounded-[1rem] border border-canvas-200/80 bg-canvas-50/92 text-ink-950 shadow-[0_12px_28px_rgba(15,23,42,0.08)]"
        end
      end

      def svg_classes
        case size
        when :xs
          "h-4 w-4"
        when :lg
          "h-6 w-6"
        else
          "h-5 w-5"
        end
      end
  end
end
