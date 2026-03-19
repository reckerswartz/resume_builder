class CreateTemplates < ActiveRecord::Migration[8.1]
  def change
    create_table :templates do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description, null: false, default: ""
      t.boolean :active, null: false, default: true
      t.jsonb :layout_config, null: false, default: {}

      t.timestamps
    end

    add_index :templates, :slug, unique: true
    add_index :templates, :active
    add_foreign_key :resumes, :templates
  end
end
