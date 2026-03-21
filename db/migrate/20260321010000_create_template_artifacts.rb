class CreateTemplateArtifacts < ActiveRecord::Migration[8.1]
  def change
    create_table :template_artifacts do |t|
      t.references :template, null: false, foreign_key: true
      t.string :artifact_type, null: false
      t.string :name, null: false
      t.text :description, default: "", null: false
      t.text :content, default: "", null: false
      t.jsonb :metadata, default: {}, null: false
      t.string :version_label
      t.string :status, default: "active", null: false
      t.timestamps
    end

    add_index :template_artifacts, [:template_id, :artifact_type]
    add_index :template_artifacts, :artifact_type
    add_index :template_artifacts, :status
  end
end
