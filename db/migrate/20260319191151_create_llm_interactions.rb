class CreateLlmInteractions < ActiveRecord::Migration[8.1]
  def change
    create_table :llm_interactions do |t|
      t.references :user, null: false, foreign_key: true
      t.references :resume, null: false, foreign_key: true
      t.string :feature_name, null: false
      t.string :status, null: false
      t.text :prompt
      t.text :response
      t.jsonb :token_usage, null: false, default: {}
      t.integer :latency_ms
      t.jsonb :metadata, null: false, default: {}
      t.text :error_message

      t.timestamps
    end

    add_index :llm_interactions, :status
    add_index :llm_interactions, :feature_name
    add_index :llm_interactions, :created_at
  end
end
