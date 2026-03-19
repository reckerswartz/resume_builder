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
            "variant" => "modern",
            "accent_color" => "#0F172A",
            "font_scale" => "base"
          }
        },
        {
          name: "Classic",
          slug: "classic",
          description: "A compact, traditional layout tuned for ATS-friendly exports.",
          layout_config: {
            "variant" => "classic",
            "accent_color" => "#1D4ED8",
            "font_scale" => "sm"
          }
        }
      ]
    end
end
