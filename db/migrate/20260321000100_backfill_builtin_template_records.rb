class BackfillBuiltinTemplateRecords < ActiveRecord::Migration[8.1]
  class TemplateRecord < ActiveRecord::Base
    self.table_name = "templates"
  end

  BUILTIN_TEMPLATES = [
    {
      name: "Modern",
      slug: "modern",
      description: "Bold headings with balanced spacing for product and tech resumes.",
      layout_config: {
        "family" => "modern",
        "variant" => "modern",
        "accent_color" => "#0F172A",
        "font_scale" => "base",
        "density" => "comfortable",
        "column_count" => "single_column",
        "theme_tone" => "slate",
        "supports_headshot" => false
      }
    },
    {
      name: "Classic",
      slug: "classic",
      description: "A compact, traditional layout tuned for ATS-friendly exports.",
      layout_config: {
        "family" => "classic",
        "variant" => "classic",
        "accent_color" => "#1D4ED8",
        "font_scale" => "sm",
        "density" => "compact",
        "column_count" => "single_column",
        "theme_tone" => "blue",
        "supports_headshot" => false
      }
    },
    {
      name: "ATS Minimal",
      slug: "ats-minimal",
      description: "A stripped-down layout tuned for ATS-friendly screening and dense professional histories.",
      layout_config: {
        "family" => "ats-minimal",
        "variant" => "ats-minimal",
        "accent_color" => "#334155",
        "font_scale" => "sm",
        "density" => "compact",
        "column_count" => "single_column",
        "theme_tone" => "slate",
        "supports_headshot" => false
      }
    },
    {
      name: "Professional",
      slug: "professional",
      description: "Balanced structure with conservative hierarchy for operations, management, and consulting resumes.",
      layout_config: {
        "family" => "professional",
        "variant" => "professional",
        "accent_color" => "#0F4C81",
        "font_scale" => "base",
        "density" => "comfortable",
        "column_count" => "single_column",
        "theme_tone" => "blue",
        "supports_headshot" => false
      }
    },
    {
      name: "Modern Clean",
      slug: "modern-clean",
      description: "Spacious contemporary cards with lighter chrome for product, design, and tech profiles.",
      layout_config: {
        "family" => "modern-clean",
        "variant" => "modern-clean",
        "accent_color" => "#0F766E",
        "font_scale" => "base",
        "density" => "relaxed",
        "column_count" => "single_column",
        "theme_tone" => "teal",
        "supports_headshot" => false
      }
    },
    {
      name: "Sidebar Accent",
      slug: "sidebar-accent",
      description: "A two-column layout that tucks supporting details into a tinted sidebar without duplicating content.",
      layout_config: {
        "family" => "sidebar-accent",
        "variant" => "sidebar-accent",
        "accent_color" => "#4338CA",
        "font_scale" => "base",
        "density" => "comfortable",
        "column_count" => "two_column",
        "theme_tone" => "indigo",
        "supports_headshot" => false,
        "sidebar_position" => "left",
        "sidebar_section_types" => %w[skills education]
      }
    },
    {
      name: "Editorial Split",
      slug: "editorial-split",
      description: "An asymmetric editorial layout with a narrow supporting column, stretched name band, and utility rail inspired by polished design-portfolio resumes.",
      layout_config: {
        "family" => "editorial-split",
        "variant" => "editorial-split",
        "accent_color" => "#D7F038",
        "font_scale" => "sm",
        "density" => "compact",
        "column_count" => "two_column",
        "theme_tone" => "lime",
        "supports_headshot" => true,
        "sidebar_section_types" => %w[education skills projects]
      }
    }
  ].freeze

  def up
    BUILTIN_TEMPLATES.each do |attributes|
      next if TemplateRecord.exists?(slug: attributes.fetch(:slug))

      timestamp = Time.current
      TemplateRecord.create!(
        name: attributes.fetch(:name),
        slug: attributes.fetch(:slug),
        description: attributes.fetch(:description),
        active: true,
        layout_config: attributes.fetch(:layout_config),
        created_at: timestamp,
        updated_at: timestamp
      )
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
