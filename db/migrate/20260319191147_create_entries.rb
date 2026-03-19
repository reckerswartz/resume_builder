class CreateEntries < ActiveRecord::Migration[8.1]
  def change
    create_table :entries do |t|
      t.references :section, null: false, foreign_key: true
      t.integer :position, null: false, default: 0
      t.jsonb :content, null: false, default: {}

      t.timestamps
    end

    add_index :entries, %i[ section_id position ]
  end
end
