class CreateReferenceCaptures < ActiveRecord::Migration[8.1]
  def change
    create_table :reference_capture_runs do |t|
      t.string :source_name, null: false
      t.string :source_base_url, null: false
      t.string :status, null: false, default: "queued"
      t.datetime :started_at
      t.datetime :finished_at
      t.string :rules_version
      t.string :app_sha
      t.string :report_directory
      t.jsonb :summary, null: false, default: {}
      t.text :notes, null: false, default: ""
      t.timestamps
    end

    add_index :reference_capture_runs, :status
    add_index :reference_capture_runs, :created_at

    create_table :reference_capture_profiles do |t|
      t.references :reference_capture_run, null: false, foreign_key: true
      t.string :name, null: false
      t.string :slug, null: false
      t.string :persona_type, null: false
      t.string :experience_level, null: false
      t.string :target_role, null: false
      t.jsonb :seed_data, null: false, default: {}
      t.timestamps
    end

    add_index :reference_capture_profiles, [ :reference_capture_run_id, :slug ], unique: true, name: "index_reference_capture_profiles_on_run_id_and_slug"

    create_table :reference_capture_steps do |t|
      t.references :reference_capture_run, null: false, foreign_key: true
      t.references :reference_capture_profile, null: false, foreign_key: true
      t.string :source, null: false
      t.string :flow_key, null: false
      t.string :step_key, null: false
      t.integer :sequence, null: false, default: 0
      t.string :page_title
      t.string :url
      t.string :capture_status, null: false, default: "captured"
      t.datetime :captured_at
      t.jsonb :form_payload, null: false, default: {}
      t.jsonb :ui_inventory, null: false, default: {}
      t.jsonb :interaction_inventory, null: false, default: {}
      t.jsonb :comparison, null: false, default: {}
      t.timestamps
    end

    add_index :reference_capture_steps, [ :reference_capture_run_id, :source, :sequence ], name: "index_reference_capture_steps_on_run_source_sequence"
    add_index :reference_capture_steps, [ :reference_capture_profile_id, :source, :sequence ], name: "index_reference_capture_steps_on_profile_source_sequence"
    add_index :reference_capture_steps, [ :reference_capture_run_id, :flow_key, :step_key, :source ], name: "index_reference_capture_steps_on_run_flow_step_source"

    create_table :reference_gap_reports do |t|
      t.references :reference_capture_run, null: false, foreign_key: true
      t.references :reference_capture_profile, null: false, foreign_key: true
      t.references :reference_capture_step, null: false, foreign_key: true
      t.string :category, null: false
      t.string :severity, null: false, default: "medium"
      t.string :status, null: false, default: "open"
      t.jsonb :evidence, null: false, default: {}
      t.jsonb :recommended_work, null: false, default: {}
      t.timestamps
    end

    add_index :reference_gap_reports, [ :reference_capture_run_id, :status ], name: "index_reference_gap_reports_on_run_id_and_status"
    add_index :reference_gap_reports, [ :reference_capture_run_id, :severity ], name: "index_reference_gap_reports_on_run_id_and_severity"
  end
end
