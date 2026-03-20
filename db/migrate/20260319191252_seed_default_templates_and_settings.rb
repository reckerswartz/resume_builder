class SeedDefaultTemplatesAndSettings < ActiveRecord::Migration[8.1]
  class TemplateRecord < ActiveRecord::Base
    self.table_name = "templates"
  end

  class PlatformSettingRecord < ActiveRecord::Base
    self.table_name = "platform_settings"
  end

  def up
    TemplateRecord.reset_column_information
    PlatformSettingRecord.reset_column_information

    templates.each do |attributes|
      TemplateRecord.find_or_create_by!(slug: attributes.fetch(:slug)) do |template|
        template.name = attributes.fetch(:name)
        template.description = attributes.fetch(:description)
        template.active = true
        template.layout_config = attributes.fetch(:layout_config)
      end
    end

    PlatformSettingRecord.find_or_create_by!(name: "global") do |setting|
      setting.feature_flags = {
        "llm_access" => false,
        "resume_suggestions" => false,
        "autofill_content" => false
      }
      setting.preferences = {
        "default_template_slug" => "modern",
        "support_email" => "support@example.com"
      }
    end
  end

  def down
    TemplateRecord.where(slug: templates.map { |template| template.fetch(:slug) }).delete_all
    PlatformSettingRecord.where(name: "global").delete_all
  end

  private
    def templates
      [
        {
          name: "Modern",
          slug: "modern",
          description: "Bold headings with balanced spacing for product and tech resumes.",
          layout_config: {
            "family" => "modern",
            "variant" => "modern",
            "accent_color" => "#0F172A",
            "font_scale" => "base",
            "density" => "comfortable"
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
            "density" => "compact"
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
            "density" => "compact"
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
            "density" => "comfortable"
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
            "density" => "relaxed"
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
            "supports_headshot" => true,
            "sidebar_section_types" => %w[education skills projects]
          }
        }
      ]
    end
end
