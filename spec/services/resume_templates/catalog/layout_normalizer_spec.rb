require 'rails_helper'

RSpec.describe ResumeTemplates::Catalog::LayoutNormalizer do
  describe '.normalize' do
    it 'returns a normalized hash with all expected keys for a valid config' do
      config = { "family" => "modern", "font_family" => "sans", "font_scale" => "base" }
      result = described_class.normalize(config)

      expect(result).to include(
        "family" => "modern",
        "variant" => "modern",
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
      )
    end

    it 'returns defaults when given a nil config' do
      result = described_class.normalize(nil)
      defaults = ResumeTemplates::Catalog.default_layout_config(family: 'modern')

      expect(result["family"]).to eq("modern")
      expect(result["font_family"]).to eq(defaults["font_family"])
      expect(result["font_scale"]).to eq(defaults["font_scale"])
      expect(result["density"]).to eq(defaults["density"])
      expect(result["accent_color"]).to eq(defaults["accent_color"])
    end

    it 'falls back to defaults for invalid option values' do
      config = {
        "family" => "classic",
        "font_family" => "comic_sans",
        "font_scale" => "xxl",
        "density" => "ultra",
        "section_spacing" => "galactic",
        "shell_style" => "neon",
        "header_style" => "funky",
        "skill_style" => "sparkle",
        "entry_style" => "hologram"
      }
      result = described_class.normalize(config)
      classic_defaults = ResumeTemplates::Catalog.default_layout_config(family: 'classic')

      expect(result["family"]).to eq("classic")
      expect(result["font_family"]).to eq(classic_defaults["font_family"])
      expect(result["font_scale"]).to eq(classic_defaults["font_scale"])
      expect(result["density"]).to eq(classic_defaults["density"])
      expect(result["section_spacing"]).to eq(classic_defaults["section_spacing"])
      expect(result["shell_style"]).to eq(classic_defaults["shell_style"])
      expect(result["header_style"]).to eq(classic_defaults["header_style"])
      expect(result["skill_style"]).to eq(classic_defaults["skill_style"])
      expect(result["entry_style"]).to eq(classic_defaults["entry_style"])
    end

    it 'preserves valid custom accent colors' do
      result = described_class.normalize({ "family" => "modern", "accent_color" => "#FF5733" })

      expect(result["accent_color"]).to eq("#FF5733")
    end

    it 'expands shorthand accent colors' do
      result = described_class.normalize({ "family" => "modern", "accent_color" => "#abc" })

      expect(result["accent_color"]).to eq("#aabbcc")
    end

    it 'falls back to the family default for invalid accent colors' do
      result = described_class.normalize({ "family" => "classic", "accent_color" => "not-a-color" })
      classic_defaults = ResumeTemplates::Catalog.default_layout_config(family: 'classic')

      expect(result["accent_color"]).to eq(classic_defaults["accent_color"])
    end

    it 'normalizes photo_slots for editorial-split family' do
      config = {
        "family" => "editorial-split",
        "photo_slots" => {
          "headshot" => {
            "portrait_shape" => "circle",
            "crop_style" => "fill",
            "background_style" => "gradient"
          }
        }
      }
      result = described_class.normalize(config)

      expect(result["photo_slots"]).to eq(
        "headshot" => {
          "portrait_shape" => "circle",
          "crop_style" => "fill",
          "background_style" => "gradient"
        }
      )
    end

    it 'returns default photo_slots when config omits them' do
      result = described_class.normalize({ "family" => "editorial-split" })

      expect(result["photo_slots"]).to eq(
        "headshot" => {
          "portrait_shape" => "rounded_square",
          "crop_style" => "cover",
          "background_style" => "studio_clean"
        }
      )
    end

    it 'returns empty photo_slots for families without headshot support' do
      result = described_class.normalize({ "family" => "modern" })

      expect(result["photo_slots"]).to eq({})
    end

    it 'resolves family from config' do
      result = described_class.normalize({ "family" => "classic" })

      expect(result["family"]).to eq("classic")
      expect(result["variant"]).to eq("classic")
    end

    it 'resolves family from variant when family is missing' do
      result = described_class.normalize({ "variant" => "sidebar-accent" })

      expect(result["family"]).to eq("sidebar-accent")
      expect(result["variant"]).to eq("sidebar-accent")
    end

    it 'uses fallback_family when config lacks family' do
      result = described_class.normalize({}, fallback_family: "professional")

      expect(result["family"]).to eq("professional")
      expect(result["variant"]).to eq("professional")
      expect(result["font_family"]).to eq("serif")
    end

    it 'falls back to default_family when both config and fallback_family are missing' do
      result = described_class.normalize({})

      expect(result["family"]).to eq("modern")
    end

    it 'produces the same result as Catalog.normalize_layout_config' do
      config = {
        "family" => "editorial-split",
        "font_family" => "mono",
        "accent_color" => "#abc",
        "density" => "compact"
      }

      expect(described_class.normalize(config)).to eq(
        ResumeTemplates::Catalog.normalize_layout_config(config)
      )
    end
  end
end
