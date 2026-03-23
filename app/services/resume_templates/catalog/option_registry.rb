module ResumeTemplates
  class Catalog
    module OptionRegistry
      def family_label(family)
        family_key = family.to_s
        default_label = FAMILY_DEFINITIONS[family_key]&.fetch(:label) || family_key.humanize

        I18n.t("resume_templates.catalog.labels.family.#{family_key}", default: default_label)
      end

      def family_options
        FAMILY_DEFINITIONS.keys.map { |key| [ family_label(key), key ] }
      end

      def font_family_options
        FONT_FAMILY_OPTIONS.map { |value, label| [ label, value ] }
      end

      def font_family_label(font_family)
        font_family_key = font_family.to_s

        I18n.t("resume_templates.catalog.labels.font_family.#{font_family_key}", default: FONT_FAMILY_OPTIONS.fetch(font_family_key, font_family_key.humanize))
      end

      def font_family_class(font_family)
        FONT_FAMILY_CLASSES.fetch(normalized_font_family(font_family), FONT_FAMILY_CLASSES.fetch("sans"))
      end

      def font_scale_options
        FONT_SCALE_OPTIONS.map { |value, label| [ label, value ] }
      end

      def font_scale_label(font_scale)
        font_scale_key = font_scale.to_s

        I18n.t("resume_templates.catalog.labels.font_scale.#{font_scale_key}", default: FONT_SCALE_OPTIONS.fetch(font_scale_key, font_scale_key.humanize))
      end

      def section_spacing_options
        SPACING_OPTIONS.map { |value, label| [ label, value ] }
      end

      def section_spacing_label(section_spacing)
        option_label("section_spacing", section_spacing)
      end

      def paragraph_spacing_options
        SPACING_OPTIONS.map { |value, label| [ label, value ] }
      end

      def paragraph_spacing_label(paragraph_spacing)
        option_label("paragraph_spacing", paragraph_spacing)
      end

      def line_spacing_options
        SPACING_OPTIONS.map { |value, label| [ label, value ] }
      end

      def line_spacing_label(line_spacing)
        option_label("line_spacing", line_spacing)
      end

      def density_options
        DENSITY_SCALES.keys.map { |density| [ density_label(density), density ] }
      end

      def density_label(density)
        option_label("density", density)
      end

      def column_count_options
        COLUMN_COUNTS.keys.map { |value| [ column_count_label(value), value ] }
      end

      def column_count_label(column_count)
        column_count_key = column_count.to_s

        I18n.t("resume_templates.catalog.labels.column_count.#{column_count_key}", default: COLUMN_COUNTS.fetch(column_count_key, column_count_key.humanize))
      end

      def theme_tone_options
        THEME_TONES.keys.map { |value| [ theme_tone_label(value), value ] }
      end

      def theme_tone_label(theme_tone)
        theme_tone_key = theme_tone.to_s

        I18n.t("resume_templates.catalog.labels.theme_tone.#{theme_tone_key}", default: THEME_TONES.fetch(theme_tone_key, theme_tone_key.humanize))
      end

      def shell_style_options
        SHELL_STYLES.map { |shell_style| [ shell_style_label(shell_style), shell_style ] }
      end

      def shell_style_label(shell_style)
        option_label("shell_style", shell_style)
      end

      def header_style_label(header_style)
        option_label("header_style", header_style)
      end

      def entry_style_label(entry_style)
        option_label("entry_style", entry_style)
      end

      def skill_style_label(skill_style)
        option_label("skill_style", skill_style)
      end

      def section_heading_style_label(section_heading_style)
        option_label("section_heading_style", section_heading_style)
      end

      def sidebar_position_label(sidebar_position)
        option_label("sidebar_position", sidebar_position)
      end

      def headshot_support_options
        %w[yes no].map { |value| [ headshot_support_label(value), value ] }
      end

      def headshot_support_label(headshot_support)
        option_label("headshot_support", headshot_support)
      end

      private
        def option_label(group, value)
          value_key = value.to_s
          return value_key if value_key.blank?

          I18n.t("resume_templates.catalog.labels.#{group}.#{value_key}", default: value_key.humanize)
        end
    end
  end
end
