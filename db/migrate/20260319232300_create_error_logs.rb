class CreateErrorLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :error_logs do |t|
      t.string :reference_id, null: false
      t.string :source, null: false
      t.string :error_class, null: false
      t.text :message, null: false
      t.jsonb :context, null: false, default: {}
      t.jsonb :backtrace_lines, null: false, default: []
      t.integer :duration_ms
      t.datetime :occurred_at, null: false

      t.timestamps
    end

    add_index :error_logs, :reference_id, unique: true
    add_index :error_logs, :source
    add_index :error_logs, :error_class
    add_index :error_logs, :occurred_at
  end
end
