module ResumeTemplates
  class Catalog
    ACCENT_COLOR_PATTERN = /\A#(?:\h{3}|\h{6})\z/
    BOOLEAN_TYPE = ActiveModel::Type::Boolean.new
    PHOTO_SLOT_NAMES = %w[headshot].freeze

    FONT_SCALES = {
      "sm" => {
        name: "text-3xl",
        headline: "text-base",
        section_title: "text-lg",
        entry_title: "text-base",
        body: "text-sm",
        meta: "text-sm",
        chip: "text-sm"
      },
      "base" => {
        name: "text-4xl",
        headline: "text-lg",
        section_title: "text-xl",
        entry_title: "text-base",
        body: "text-sm",
        meta: "text-sm",
        chip: "text-sm"
      },
      "lg" => {
        name: "text-5xl",
        headline: "text-xl",
        section_title: "text-2xl",
        entry_title: "text-lg",
        body: "text-base",
        meta: "text-base",
        chip: "text-base"
      }
    }.freeze

    DENSITY_SCALES = {
      "compact" => {
        container_padding: "p-6 sm:p-8",
        header_padding_bottom: "pb-5",
        summary_margin_top: "mt-4",
        section_stack: "mt-7 space-y-7",
        section_heading_spacing: "mb-3",
        entry_stack: "mt-4 space-y-4",
        entry_body_spacing: "mt-2"
      },
      "comfortable" => {
        container_padding: "p-8 sm:p-10",
        header_padding_bottom: "pb-6",
        summary_margin_top: "mt-5",
        section_stack: "mt-8 space-y-8",
        section_heading_spacing: "mb-4",
        entry_stack: "mt-5 space-y-5",
        entry_body_spacing: "mt-3"
      },
      "relaxed" => {
        container_padding: "p-10 sm:p-12",
        header_padding_bottom: "pb-7",
        summary_margin_top: "mt-6",
        section_stack: "mt-10 space-y-10",
        section_heading_spacing: "mb-5",
        entry_stack: "mt-6 space-y-6",
        entry_body_spacing: "mt-4"
      }
    }.freeze

    SHELL_STYLES = %w[flat card].freeze
    HEADER_STYLES = %w[rule split].freeze
    SECTION_HEADING_STYLES = %w[rule marker].freeze
    SKILL_STYLES = %w[inline chips].freeze
    ENTRY_STYLES = %w[list cards].freeze
    COLUMN_COUNTS = {
      "single_column" => "1 column",
      "two_column" => "2 columns"
    }.freeze
    THEME_TONES = {
      "slate" => "Slate",
      "blue" => "Blue",
      "teal" => "Teal",
      "indigo" => "Indigo",
      "lime" => "Lime"
    }.freeze

    FAMILY_DEFINITIONS = {
      "modern" => {
        label: "Modern",
        component_class_name: "ResumeTemplates::ModernComponent",
        defaults: {
          "family" => "modern",
          "variant" => "modern",
          "accent_color" => "#0F172A",
          "font_scale" => "base",
          "density" => "comfortable",
          "column_count" => "single_column",
          "theme_tone" => "slate",
          "supports_headshot" => false,
          "shell_style" => "card",
          "header_style" => "split",
          "section_heading_style" => "marker",
          "skill_style" => "chips",
          "entry_style" => "cards"
        }
      },
      "classic" => {
        label: "Classic",
        component_class_name: "ResumeTemplates::ClassicComponent",
        defaults: {
          "family" => "classic",
          "variant" => "classic",
          "accent_color" => "#1D4ED8",
          "font_scale" => "sm",
          "density" => "compact",
          "column_count" => "single_column",
          "theme_tone" => "blue",
          "supports_headshot" => false,
          "shell_style" => "flat",
          "header_style" => "rule",
          "section_heading_style" => "rule",
          "skill_style" => "inline",
          "entry_style" => "list"
        }
      },
      "ats-minimal" => {
        label: "ATS Minimal",
        component_class_name: "ResumeTemplates::AtsMinimalComponent",
        defaults: {
          "family" => "ats-minimal",
          "variant" => "ats-minimal",
          "accent_color" => "#334155",
          "font_scale" => "sm",
          "density" => "compact",
          "column_count" => "single_column",
          "theme_tone" => "slate",
          "supports_headshot" => false,
          "shell_style" => "flat",
          "header_style" => "rule",
          "section_heading_style" => "rule",
          "skill_style" => "inline",
          "entry_style" => "list"
        }
      },
      "professional" => {
        label: "Professional",
        component_class_name: "ResumeTemplates::ProfessionalComponent",
        defaults: {
          "family" => "professional",
          "variant" => "professional",
          "accent_color" => "#0F4C81",
          "font_scale" => "base",
          "density" => "comfortable",
          "column_count" => "single_column",
          "theme_tone" => "blue",
          "supports_headshot" => false,
          "shell_style" => "flat",
          "header_style" => "split",
          "section_heading_style" => "rule",
          "skill_style" => "inline",
          "entry_style" => "list"
        }
      },
      "modern-clean" => {
        label: "Modern Clean",
        component_class_name: "ResumeTemplates::ModernCleanComponent",
        defaults: {
          "family" => "modern-clean",
          "variant" => "modern-clean",
          "accent_color" => "#0F766E",
          "font_scale" => "base",
          "density" => "relaxed",
          "column_count" => "single_column",
          "theme_tone" => "teal",
          "supports_headshot" => false,
          "shell_style" => "card",
          "header_style" => "split",
          "section_heading_style" => "rule",
          "skill_style" => "chips",
          "entry_style" => "cards"
        }
      },
      "sidebar-accent" => {
        label: "Sidebar Accent",
        component_class_name: "ResumeTemplates::SidebarAccentComponent",
        defaults: {
          "family" => "sidebar-accent",
          "variant" => "sidebar-accent",
          "accent_color" => "#4338CA",
          "font_scale" => "base",
          "density" => "comfortable",
          "column_count" => "two_column",
          "theme_tone" => "indigo",
          "supports_headshot" => false,
          "shell_style" => "card",
          "header_style" => "split",
          "section_heading_style" => "rule",
          "skill_style" => "chips",
          "entry_style" => "list",
          "sidebar_position" => "left",
          "sidebar_section_types" => %w[skills education]
        }
      },
      "editorial-split" => {
        label: "Editorial Split",
        component_class_name: "ResumeTemplates::EditorialSplitComponent",
        defaults: {
          "family" => "editorial-split",
          "variant" => "editorial-split",
          "accent_color" => "#D7F038",
          "font_scale" => "sm",
          "density" => "compact",
          "column_count" => "two_column",
          "theme_tone" => "lime",
          "supports_headshot" => true,
          "photo_slots" => {
            "headshot" => {
              "portrait_shape" => "rounded_square",
              "crop_style" => "cover",
              "background_style" => "studio_clean"
            }
          },
          "shell_style" => "flat",
          "header_style" => "split",
          "section_heading_style" => "rule",
          "skill_style" => "inline",
          "entry_style" => "list",
          "sidebar_position" => "left",
          "sidebar_section_types" => %w[education skills projects]
        }
      }
    }.freeze

    class << self
      def default_family
        "modern"
      end

      def families
        FAMILY_DEFINITIONS.keys
      end

      def family_label(family)
        family_key = family.to_s
        default_label = FAMILY_DEFINITIONS[family_key]&.fetch(:label) || family_key.humanize

        I18n.t("resume_templates.catalog.labels.family.#{family_key}", default: default_label)
      end

      def family_options
        FAMILY_DEFINITIONS.keys.map { |key| [ family_label(key), key ] }
      end

      def font_scale_options
        [ [ "Small", "sm" ], [ "Base", "base" ], [ "Large", "lg" ] ]
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

      def default_layout_config(family: default_family)
        family_definition_for(family).fetch(:defaults).deep_dup
      end

      def normalize_layout_config(layout_config, fallback_family: nil)
        config = (layout_config || {}).deep_stringify_keys
        family = resolve_family(config, fallback_family:)
        defaults = default_layout_config(family:)
        normalized = defaults.merge(config)

        normalized["family"] = family
        normalized["variant"] = family
        normalized["accent_color"] = normalize_accent_color(config["accent_color"], defaults.fetch("accent_color"))
        normalized["font_scale"] = normalize_option(config["font_scale"], FONT_SCALES.keys, defaults.fetch("font_scale"))
        normalized["density"] = normalize_option(config["density"], DENSITY_SCALES.keys, defaults.fetch("density"))
        normalized["column_count"] = normalize_option(config["column_count"], COLUMN_COUNTS.keys, defaults.fetch("column_count"))
        normalized["theme_tone"] = normalize_option(config["theme_tone"], THEME_TONES.keys, defaults.fetch("theme_tone"))
        normalized["supports_headshot"] = BOOLEAN_TYPE.cast(config.key?("supports_headshot") ? config["supports_headshot"] : defaults.fetch("supports_headshot"))
        normalized["photo_slots"] = normalize_photo_slots(config["photo_slots"], defaults.fetch("photo_slots", {}))
        normalized["shell_style"] = normalize_option(config["shell_style"], SHELL_STYLES, defaults.fetch("shell_style"))
        normalized["header_style"] = normalize_option(config["header_style"], HEADER_STYLES, defaults.fetch("header_style"))
        normalized["section_heading_style"] = normalize_option(config["section_heading_style"], SECTION_HEADING_STYLES, defaults.fetch("section_heading_style"))
        normalized["skill_style"] = normalize_option(config["skill_style"], SKILL_STYLES, defaults.fetch("skill_style"))
        normalized["entry_style"] = normalize_option(config["entry_style"], ENTRY_STYLES, defaults.fetch("entry_style"))
        normalized
      end

      def component_class_for(layout_config_or_family, fallback_family: nil)
        family = resolve_family(extract_layout_config(layout_config_or_family), fallback_family:)
        family_definition_for(family).fetch(:component_class_name).constantize
      end

      def normalized_accent_color(value, fallback: default_layout_config.fetch("accent_color"))
        normalize_accent_color(value, fallback)
      end

      def typography_scale(font_scale)
        FONT_SCALES.fetch(normalize_option(font_scale, FONT_SCALES.keys, "base"))
      end

      def density_scale(density)
        DENSITY_SCALES.fetch(normalize_option(density, DENSITY_SCALES.keys, "comfortable"))
      end

      private
        def extract_layout_config(layout_config_or_family)
          case layout_config_or_family
          when String, Symbol
            { "family" => layout_config_or_family.to_s }
          when Hash
            layout_config_or_family
          else
            {}
          end
        end

        def resolve_family(config, fallback_family: nil)
          normalized = (config || {}).deep_stringify_keys

          normalized["family"].presence_in(families) ||
            normalized["variant"].presence_in(families) ||
            fallback_family.to_s.presence_in(families) ||
            default_family
        end

        def family_definition_for(family)
          FAMILY_DEFINITIONS.fetch(resolve_family({ "family" => family }))
        end

        def normalize_accent_color(value, fallback)
          candidate = value.to_s.strip
          return fallback unless candidate.match?(ACCENT_COLOR_PATTERN)

          return candidate if candidate.length == 7

          "##{candidate.delete_prefix("#").chars.flat_map { |character| [ character, character ] }.join}"
        end

        def normalize_option(value, allowed_values, fallback)
          value.to_s.presence_in(allowed_values) || fallback
        end

        def normalize_photo_slots(value, fallback)
          raw_slots = value.is_a?(Hash) ? value.deep_stringify_keys : fallback.deep_stringify_keys

          PHOTO_SLOT_NAMES.each_with_object({}) do |slot_name, slots|
            next unless raw_slots.key?(slot_name)

            slot_config = raw_slots.fetch(slot_name, {}).deep_stringify_keys
            slots[slot_name] = {
              "portrait_shape" => slot_config["portrait_shape"].presence || "rounded_square",
              "crop_style" => slot_config["crop_style"].presence || "cover",
              "background_style" => slot_config["background_style"].presence || "studio_clean"
            }
          end
        end

        def option_label(group, value)
          value_key = value.to_s
          return value_key if value_key.blank?

          I18n.t("resume_templates.catalog.labels.#{group}.#{value_key}", default: value_key.humanize)
        end
    end
  end
end
