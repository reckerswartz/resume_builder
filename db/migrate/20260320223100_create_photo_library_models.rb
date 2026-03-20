class CreatePhotoLibraryModels < ActiveRecord::Migration[8.1]
  def change
    create_table :photo_profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.string :status, null: false, default: "draft"
      t.text :notes
      t.jsonb :preferences, null: false, default: {}
      t.timestamps
    end

    add_index :photo_profiles, [ :user_id, :name ]
    add_index :photo_profiles, :status

    create_table :photo_assets do |t|
      t.references :photo_profile, null: false, foreign_key: true
      t.references :source_asset, null: true, foreign_key: { to_table: :photo_assets }
      t.string :asset_kind, null: false, default: "source"
      t.string :status, null: false, default: "uploaded"
      t.jsonb :metadata, null: false, default: {}
      t.timestamps
    end

    add_index :photo_assets, [ :photo_profile_id, :asset_kind ]
    add_index :photo_assets, :status

    create_table :photo_processing_runs do |t|
      t.references :photo_profile, null: false, foreign_key: true
      t.references :resume, null: true, foreign_key: true
      t.references :template, null: true, foreign_key: true
      t.references :job_log, null: true, foreign_key: true
      t.string :workflow_type, null: false
      t.string :status, null: false, default: "queued"
      t.text :prompt_text
      t.jsonb :selected_model_ids, null: false, default: []
      t.jsonb :input_asset_ids, null: false, default: []
      t.jsonb :output_asset_ids, null: false, default: []
      t.jsonb :request_payload, null: false, default: {}
      t.jsonb :response_payload, null: false, default: {}
      t.text :error_summary
      t.text :next_step_guidance
      t.jsonb :metadata, null: false, default: {}
      t.datetime :started_at
      t.datetime :finished_at
      t.timestamps
    end

    add_index :photo_processing_runs, :workflow_type
    add_index :photo_processing_runs, :status
    add_index :photo_processing_runs, :created_at

    create_table :resume_photo_selections do |t|
      t.references :resume, null: false, foreign_key: true
      t.references :template, null: false, foreign_key: true
      t.references :photo_asset, null: false, foreign_key: true
      t.string :slot_name, null: false
      t.string :status, null: false, default: "active"
      t.timestamps
    end

    add_index :resume_photo_selections,
      [ :resume_id, :template_id, :slot_name ],
      unique: true,
      name: "index_resume_photo_selections_on_resume_template_slot"

    add_reference :photo_profiles,
      :selected_source_photo_asset,
      null: true,
      foreign_key: { to_table: :photo_assets }
  end
end
