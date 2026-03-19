class CreateJobLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :job_logs do |t|
      t.string :active_job_id
      t.string :job_type, null: false
      t.string :queue_name, null: false
      t.string :status, null: false
      t.jsonb :input, null: false, default: {}
      t.jsonb :output, null: false, default: {}
      t.jsonb :error_details, null: false, default: {}
      t.integer :duration_ms
      t.datetime :started_at
      t.datetime :finished_at

      t.timestamps
    end

    add_index :job_logs, :active_job_id, unique: true
    add_index :job_logs, :job_type
    add_index :job_logs, :status
    add_index :job_logs, :created_at
  end
end
