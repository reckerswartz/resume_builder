class CreateSections < ActiveRecord::Migration[8.1]
  def change
    create_table :sections do |t|
      t.references :resume, null: false, foreign_key: true
      t.string :title, null: false
      t.string :section_type, null: false
      t.integer :position, null: false, default: 0
      t.jsonb :settings, null: false, default: {}

      t.timestamps
    end

    add_index :sections, %i[ resume_id position ]
    add_index :sections, %i[ resume_id section_type ]
  end
end
