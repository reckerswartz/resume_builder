class EnableHeadshotSupportForEditorialSplitTemplates < ActiveRecord::Migration[8.1]
  class TemplateRecord < ActiveRecord::Base
    self.table_name = "templates"
  end

  def up
    editorial_split_templates.find_each do |template|
      layout_config = (template.layout_config || {}).deep_stringify_keys
      template.update_columns(
        layout_config: layout_config.merge("supports_headshot" => true),
        updated_at: Time.current
      )
    end
  end

  def down
    editorial_split_templates.find_each do |template|
      layout_config = (template.layout_config || {}).deep_stringify_keys
      template.update_columns(
        layout_config: layout_config.merge("supports_headshot" => false),
        updated_at: Time.current
      )
    end
  end

  private
    def editorial_split_templates
      TemplateRecord.where(slug: "editorial-split").or(
        TemplateRecord.where("layout_config ->> 'family' = ?", "editorial-split")
      )
    end
end
