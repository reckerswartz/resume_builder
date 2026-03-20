class AddLlmProvidersModelsAndAssignments < ActiveRecord::Migration[8.1]
  def change
    create_table :llm_providers do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.string :adapter, null: false
      t.string :base_url, null: false
      t.string :api_key_env_var
      t.boolean :active, null: false, default: true
      t.jsonb :settings, null: false, default: {}

      t.timestamps
    end

    add_index :llm_providers, :slug, unique: true
    add_index :llm_providers, :active

    create_table :llm_models do |t|
      t.references :llm_provider, null: false, foreign_key: true
      t.string :name, null: false
      t.string :identifier, null: false
      t.boolean :active, null: false, default: true
      t.boolean :supports_text, null: false, default: true
      t.boolean :supports_vision, null: false, default: false
      t.jsonb :settings, null: false, default: {}
      t.jsonb :metadata, null: false, default: {}

      t.timestamps
    end

    add_index :llm_models, [ :llm_provider_id, :identifier ], unique: true
    add_index :llm_models, :active

    create_table :llm_model_assignments do |t|
      t.references :llm_model, null: false, foreign_key: true
      t.string :role, null: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    add_index :llm_model_assignments, [ :llm_model_id, :role ], unique: true
    add_index :llm_model_assignments, [ :role, :position ]

    change_table :llm_interactions do |t|
      t.references :llm_provider, foreign_key: true
      t.references :llm_model, foreign_key: true
      t.string :role
    end

    add_index :llm_interactions, :role
  end
end
