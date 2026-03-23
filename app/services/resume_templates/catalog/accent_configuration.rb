module ResumeTemplates
  class Catalog
    module AccentConfiguration
      ACCENT_COLOR_PATTERN = /\A#(?:\h{3}|\h{6})\z/
      ACCENT_TONE_COLORS = {
        "slate" => "#334155",
        "blue" => "#1D4ED8",
        "teal" => "#0D6B63",
        "indigo" => "#4338CA",
        "lime" => "#D7F038"
      }.freeze
      ACCENT_VARIANT_TONES = {
        "slate" => %w[blue teal],
        "blue" => %w[slate indigo],
        "teal" => %w[blue slate],
        "indigo" => %w[blue slate],
        "lime" => %w[slate indigo]
      }.freeze
      ACCENT_COLOR_PALETTE = [
        { key: "slate",    hex: "#334155", label: "Slate" },
        { key: "gray",     hex: "#374151", label: "Gray" },
        { key: "zinc",     hex: "#3F3F46", label: "Zinc" },
        { key: "stone",    hex: "#44403C", label: "Stone" },
        { key: "red",      hex: "#DC2626", label: "Red" },
        { key: "rose",     hex: "#E11D48", label: "Rose" },
        { key: "orange",   hex: "#EA580C", label: "Orange" },
        { key: "amber",    hex: "#D97706", label: "Amber" },
        { key: "emerald",  hex: "#059669", label: "Emerald" },
        { key: "teal",     hex: "#0D6B63", label: "Teal" },
        { key: "cyan",     hex: "#0891B2", label: "Cyan" },
        { key: "sky",      hex: "#0284C7", label: "Sky" },
        { key: "blue",     hex: "#1D4ED8", label: "Blue" },
        { key: "indigo",   hex: "#4338CA", label: "Indigo" },
        { key: "violet",   hex: "#7C3AED", label: "Violet" },
        { key: "purple",   hex: "#9333EA", label: "Purple" },
        { key: "fuchsia",  hex: "#C026D3", label: "Fuchsia" },
        { key: "pink",     hex: "#DB2777", label: "Pink" },
        { key: "navy",     hex: "#0F4C81", label: "Navy" },
        { key: "charcoal", hex: "#0F172A", label: "Charcoal" },
        { key: "lime",     hex: "#D7F038", label: "Lime" }
      ].freeze

      def accent_color_palette
        ACCENT_COLOR_PALETTE
      end

      def default_accent_color_for(layout_config_or_family)
        config = normalize_layout_config(extract_layout_config(layout_config_or_family))
        config.fetch("accent_color")
      end

      def normalized_accent_color(value, fallback: default_layout_config.fetch("accent_color"))
        normalize_accent_color(value, fallback)
      end

      def accent_variants(layout_config_or_family, selected_accent_color: nil)
        layout_config = normalize_layout_config(extract_layout_config(layout_config_or_family))
        theme_tone = layout_config.fetch("theme_tone")
        default_accent_color = layout_config.fetch("accent_color")
        variants = [
          accent_variant_definition(theme_tone, accent_color: default_accent_color, default: true)
        ]

        ACCENT_VARIANT_TONES.fetch(theme_tone, []).each do |variant_tone|
          variants << accent_variant_definition(variant_tone, accent_color: ACCENT_TONE_COLORS.fetch(variant_tone))
        end

        return variants if selected_accent_color.blank?

        normalized_selected_color = normalize_accent_color(selected_accent_color, default_accent_color)
        return variants if variants.any? { |variant| variant.fetch(:accent_color) == normalized_selected_color }

        variants + [
          {
            key: "custom",
            label: I18n.t("resume_templates.catalog.labels.accent_variant.custom"),
            accent_color: normalized_selected_color,
            default: false,
            custom: true
          }
        ]
      end

      private
        def normalize_accent_color(value, fallback)
          candidate = value.to_s.strip
          return fallback unless candidate.match?(ACCENT_COLOR_PATTERN)

          return candidate if candidate.length == 7

          "##{candidate.delete_prefix("#").chars.flat_map { |character| [ character, character ] }.join}"
        end

        def accent_variant_definition(theme_tone, accent_color:, default: false)
          {
            key: theme_tone.to_s,
            label: theme_tone_label(theme_tone),
            accent_color: accent_color,
            default: default,
            custom: false
          }
        end
    end
  end
end
