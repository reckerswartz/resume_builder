module ResumeTemplates
  class Catalog
    ACCENT_COLOR_PATTERN = /\A#(?:\h{3}|\h{6})\z/
    BOOLEAN_TYPE = ActiveModel::Type::Boolean.new
    PHOTO_SLOT_NAMES = %w[headshot].freeze
    FONT_FAMILY_OPTIONS = {
      "sans" => "Sans-serif",
      "serif" => "Serif",
      "mono" => "Monospace"
    }.freeze

    FONT_FAMILY_CLASSES = {
      "sans" => "font-sans",
      "serif" => "font-serif",
      "mono" => "font-mono"
    }.freeze

    FONT_SCALE_OPTIONS = {
      "sm" => "Small",
      "base" => "Base",
      "lg" => "Large"
    }.freeze

    SPACING_OPTIONS = {
      "tight" => "Tight",
      "standard" => "Standard",
      "relaxed" => "Relaxed"
    }.freeze

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

    SECTION_SPACING_SCALES = {
      "tight" => {
        stack_margin_top: "mt-7",
        stack_space: "space-y-7",
        compact_stack_space: "space-y-4",
        content_margin_top: "mt-3"
      },
      "standard" => {
        stack_margin_top: "mt-8",
        stack_space: "space-y-8",
        compact_stack_space: "space-y-5",
        content_margin_top: "mt-3"
      },
      "relaxed" => {
        stack_margin_top: "mt-10",
        stack_space: "space-y-10",
        compact_stack_space: "space-y-6",
        content_margin_top: "mt-4"
      }
    }.freeze

    PARAGRAPH_SPACING_SCALES = {
      "tight" => {
        summary_margin_top: "mt-4",
        entry_body_spacing: "mt-2"
      },
      "standard" => {
        summary_margin_top: "mt-5",
        entry_body_spacing: "mt-3"
      },
      "relaxed" => {
        summary_margin_top: "mt-6",
        entry_body_spacing: "mt-4"
      }
    }.freeze

    LINE_SPACING_SCALES = {
      "tight" => {
        body: "leading-5",
        relaxed_body: "leading-6",
        meta: "leading-5"
      },
      "standard" => {
        body: "leading-6",
        relaxed_body: "leading-7",
        meta: "leading-6"
      },
      "relaxed" => {
        body: "leading-7",
        relaxed_body: "leading-8",
        meta: "leading-7"
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
    ACCENT_TONE_COLORS = {
      "slate" => "#334155",
      "blue" => "#1D4ED8",
      "teal" => "#0F766E",
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
      { key: "teal",     hex: "#0F766E", label: "Teal" },
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

    FAMILY_DEFINITIONS = {
      "modern" => {
        label: "Modern",
        component_class_name: "ResumeTemplates::ModernComponent",
        defaults: {
          "family" => "modern",
          "variant" => "modern",
          "accent_color" => "#0F172A",
          "font_family" => "sans",
          "font_scale" => "base",
          "density" => "comfortable",
          "section_spacing" => "standard",
          "paragraph_spacing" => "standard",
          "line_spacing" => "standard",
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
          "font_family" => "serif",
          "font_scale" => "sm",
          "density" => "compact",
          "section_spacing" => "tight",
          "paragraph_spacing" => "tight",
          "line_spacing" => "standard",
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
          "font_family" => "sans",
          "font_scale" => "sm",
          "density" => "compact",
          "section_spacing" => "tight",
          "paragraph_spacing" => "tight",
          "line_spacing" => "standard",
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
          "font_family" => "serif",
          "font_scale" => "base",
          "density" => "comfortable",
          "section_spacing" => "standard",
          "paragraph_spacing" => "standard",
          "line_spacing" => "standard",
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
          "font_family" => "sans",
          "font_scale" => "base",
          "density" => "compact",
          "section_spacing" => "tight",
          "paragraph_spacing" => "tight",
          "line_spacing" => "tight",
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
          "font_family" => "sans",
          "font_scale" => "base",
          "density" => "comfortable",
          "section_spacing" => "standard",
          "paragraph_spacing" => "standard",
          "line_spacing" => "standard",
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
          "font_family" => "sans",
          "font_scale" => "sm",
          "density" => "compact",
          "section_spacing" => "standard",
          "paragraph_spacing" => "standard",
          "line_spacing" => "standard",
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

      def accent_color_palette
        ACCENT_COLOR_PALETTE
      end

      def default_accent_color_for(layout_config_or_family)
        config = normalize_layout_config(extract_layout_config(layout_config_or_family))
        config.fetch("accent_color")
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
        normalized["font_family"] = normalize_option(config["font_family"], FONT_FAMILY_OPTIONS.keys, defaults.fetch("font_family"))
        normalized["font_scale"] = normalize_option(config["font_scale"], FONT_SCALES.keys, defaults.fetch("font_scale"))
        normalized["density"] = normalize_option(config["density"], DENSITY_SCALES.keys, defaults.fetch("density"))
        normalized["section_spacing"] = normalize_option(config["section_spacing"], SECTION_SPACING_SCALES.keys, defaults.fetch("section_spacing"))
        normalized["paragraph_spacing"] = normalize_option(config["paragraph_spacing"], PARAGRAPH_SPACING_SCALES.keys, defaults.fetch("paragraph_spacing"))
        normalized["line_spacing"] = normalize_option(config["line_spacing"], LINE_SPACING_SCALES.keys, defaults.fetch("line_spacing"))
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

      def normalized_font_family(value, fallback: default_layout_config.fetch("font_family"))
        normalize_option(value, FONT_FAMILY_OPTIONS.keys, fallback)
      end

      def normalized_font_scale(value, fallback: default_layout_config.fetch("font_scale"))
        normalize_option(value, FONT_SCALES.keys, fallback)
      end

      def normalized_density(value, fallback: default_layout_config.fetch("density"))
        normalize_option(value, DENSITY_SCALES.keys, fallback)
      end

      def normalized_section_spacing(value, fallback: default_layout_config.fetch("section_spacing"))
        normalize_option(value, SECTION_SPACING_SCALES.keys, fallback)
      end

      def normalized_paragraph_spacing(value, fallback: default_layout_config.fetch("paragraph_spacing"))
        normalize_option(value, PARAGRAPH_SPACING_SCALES.keys, fallback)
      end

      def normalized_line_spacing(value, fallback: default_layout_config.fetch("line_spacing"))
        normalize_option(value, LINE_SPACING_SCALES.keys, fallback)
      end

      def typography_scale(font_scale)
        FONT_SCALES.fetch(normalized_font_scale(font_scale, fallback: "base"))
      end

      def density_scale(density)
        DENSITY_SCALES.fetch(normalized_density(density, fallback: "comfortable"))
      end

      def section_spacing_scale(section_spacing)
        SECTION_SPACING_SCALES.fetch(normalized_section_spacing(section_spacing, fallback: "standard"))
      end

      def paragraph_spacing_scale(paragraph_spacing)
        PARAGRAPH_SPACING_SCALES.fetch(normalized_paragraph_spacing(paragraph_spacing, fallback: "standard"))
      end

      def line_spacing_scale(line_spacing)
        LINE_SPACING_SCALES.fetch(normalized_line_spacing(line_spacing, fallback: "standard"))
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
