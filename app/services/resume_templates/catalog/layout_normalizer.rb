module ResumeTemplates
  class Catalog
    module LayoutNormalizer
      class << self
        def normalize(layout_config, fallback_family: nil)
          config = (layout_config || {}).deep_stringify_keys
          family = resolve_family(config, fallback_family:)
          defaults = Catalog.default_layout_config(family:)
          normalized = defaults.merge(config)

          normalized["family"] = family
          normalized["variant"] = family
          normalized["accent_color"] = Catalog.send(:normalize_accent_color, config["accent_color"], defaults.fetch("accent_color"))
          normalized["font_family"] = normalize_option(config["font_family"], Catalog::FONT_FAMILY_OPTIONS.keys, defaults.fetch("font_family"))
          normalized["font_scale"] = normalize_option(config["font_scale"], Catalog::FONT_SCALES.keys, defaults.fetch("font_scale"))
          normalized["density"] = normalize_option(config["density"], Catalog::DENSITY_SCALES.keys, defaults.fetch("density"))
          normalized["section_spacing"] = normalize_option(config["section_spacing"], Catalog::SECTION_SPACING_SCALES.keys, defaults.fetch("section_spacing"))
          normalized["paragraph_spacing"] = normalize_option(config["paragraph_spacing"], Catalog::PARAGRAPH_SPACING_SCALES.keys, defaults.fetch("paragraph_spacing"))
          normalized["line_spacing"] = normalize_option(config["line_spacing"], Catalog::LINE_SPACING_SCALES.keys, defaults.fetch("line_spacing"))
          normalized["column_count"] = normalize_option(config["column_count"], Catalog::COLUMN_COUNTS.keys, defaults.fetch("column_count"))
          normalized["theme_tone"] = normalize_option(config["theme_tone"], Catalog::THEME_TONES.keys, defaults.fetch("theme_tone"))
          normalized["supports_headshot"] = Catalog::BOOLEAN_TYPE.cast(config.key?("supports_headshot") ? config["supports_headshot"] : defaults.fetch("supports_headshot"))
          normalized["photo_slots"] = normalize_photo_slots(config["photo_slots"], defaults.fetch("photo_slots", {}))
          normalized["shell_style"] = normalize_option(config["shell_style"], Catalog::SHELL_STYLES, defaults.fetch("shell_style"))
          normalized["header_style"] = normalize_option(config["header_style"], Catalog::HEADER_STYLES, defaults.fetch("header_style"))
          normalized["section_heading_style"] = normalize_option(config["section_heading_style"], Catalog::SECTION_HEADING_STYLES, defaults.fetch("section_heading_style"))
          normalized["skill_style"] = normalize_option(config["skill_style"], Catalog::SKILL_STYLES, defaults.fetch("skill_style"))
          normalized["entry_style"] = normalize_option(config["entry_style"], Catalog::ENTRY_STYLES, defaults.fetch("entry_style"))
          normalized
        end

        private
          def resolve_family(config, fallback_family: nil)
            normalized = (config || {}).deep_stringify_keys

            normalized["family"].presence_in(Catalog.families) ||
              normalized["variant"].presence_in(Catalog.families) ||
              fallback_family.to_s.presence_in(Catalog.families) ||
              Catalog.default_family
          end

          def normalize_option(value, allowed_values, fallback)
            value.to_s.presence_in(allowed_values) || fallback
          end

          def normalize_photo_slots(value, fallback)
            raw_slots = value.is_a?(Hash) ? value.deep_stringify_keys : fallback.deep_stringify_keys

            Catalog::PHOTO_SLOT_NAMES.each_with_object({}) do |slot_name, slots|
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
end
