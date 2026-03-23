module ResumeTemplates
  class Catalog
    ACCENT_COLOR_PATTERN = AccentConfiguration::ACCENT_COLOR_PATTERN
    ACCENT_TONE_COLORS = AccentConfiguration::ACCENT_TONE_COLORS
    ACCENT_VARIANT_TONES = AccentConfiguration::ACCENT_VARIANT_TONES
    ACCENT_COLOR_PALETTE = AccentConfiguration::ACCENT_COLOR_PALETTE
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
          "accent_color" => "#0D6B63",
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

    extend AccentConfiguration
    extend OptionRegistry

    class << self
      def default_family
        "modern"
      end

      def families
        FAMILY_DEFINITIONS.keys
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
    end
  end
end
