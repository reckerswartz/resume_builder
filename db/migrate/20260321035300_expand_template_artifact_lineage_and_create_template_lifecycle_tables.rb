class ExpandTemplateArtifactLineageAndCreateTemplateLifecycleTables < ActiveRecord::Migration[8.1]
  def up
    add_reference :template_artifacts, :parent_artifact, foreign_key: { to_table: :template_artifacts }
    add_column :template_artifacts, :identifier, :string
    add_column :template_artifacts, :lineage_kind, :string, null: false, default: "documentation"
    add_column :template_artifacts, :source_url, :string
    add_column :template_artifacts, :source_signature, :string
    add_column :template_artifacts, :immutable_source, :boolean, null: false, default: false
    add_column :template_artifacts, :validated_at, :datetime

    add_index :template_artifacts, :identifier, unique: true
    add_index :template_artifacts, :lineage_kind
    add_index :template_artifacts, :source_url
    add_index :template_artifacts, :source_signature
    add_index :template_artifacts, :immutable_source

    create_table :template_implementations do |t|
      t.references :template, null: false, foreign_key: true
      t.references :source_artifact, foreign_key: { to_table: :template_artifacts }
      t.string :identifier, null: false
      t.string :name, null: false
      t.string :status, null: false, default: "draft"
      t.string :renderer_family, null: false
      t.jsonb :render_profile, null: false, default: {}
      t.text :notes, null: false, default: ""
      t.jsonb :metadata, null: false, default: {}
      t.datetime :validated_at
      t.datetime :seeded_at
      t.timestamps
    end

    add_index :template_implementations, :identifier, unique: true
    add_index :template_implementations, :status
    add_index :template_implementations, [ :template_id, :status ]

    create_table :template_validation_runs do |t|
      t.references :template, null: false, foreign_key: true
      t.references :template_implementation, foreign_key: true
      t.references :reference_artifact, foreign_key: { to_table: :template_artifacts }
      t.string :identifier, null: false
      t.string :validation_type, null: false
      t.string :status, null: false, default: "pending"
      t.string :validator_name
      t.text :notes, null: false, default: ""
      t.jsonb :metrics, null: false, default: {}
      t.jsonb :metadata, null: false, default: {}
      t.datetime :validated_at
      t.timestamps
    end

    add_index :template_validation_runs, :identifier, unique: true
    add_index :template_validation_runs, :status
    add_index :template_validation_runs, [ :template_id, :validation_type ]

    backfill_template_artifact_lifecycle_data
  end

  def down
    drop_table :template_validation_runs
    drop_table :template_implementations

    remove_index :template_artifacts, :immutable_source
    remove_index :template_artifacts, :source_signature
    remove_index :template_artifacts, :source_url
    remove_index :template_artifacts, :lineage_kind
    remove_index :template_artifacts, :identifier

    remove_column :template_artifacts, :validated_at
    remove_column :template_artifacts, :immutable_source
    remove_column :template_artifacts, :source_signature
    remove_column :template_artifacts, :source_url
    remove_column :template_artifacts, :lineage_kind
    remove_column :template_artifacts, :identifier
    remove_reference :template_artifacts, :parent_artifact, foreign_key: { to_table: :template_artifacts }
  end

  private
    def backfill_template_artifact_lifecycle_data
      execute <<~SQL.squish
        UPDATE template_artifacts
        SET identifier = CONCAT('artifact-', id)
        WHERE identifier IS NULL
      SQL

      execute <<~SQL.squish
        UPDATE template_artifacts
        SET source_url = NULLIF(metadata ->> 'reference_source_url', '')
        WHERE source_url IS NULL
      SQL

      execute <<~SQL.squish
        UPDATE template_artifacts
        SET source_signature = CONCAT_WS(':', template_id, artifact_type, COALESCE(NULLIF(version_label, ''), 'baseline'))
        WHERE source_signature IS NULL
      SQL

      execute <<~SQL.squish
        UPDATE template_artifacts
        SET lineage_kind = CASE
          WHEN artifact_type IN ('source_capture', 'reference_design', 'reference_image') THEN 'source'
          WHEN artifact_type IN ('version_snapshot', 'implementation_snapshot', 'seed_snapshot') THEN 'derived'
          WHEN artifact_type IN ('discrepancy_report', 'validation_snapshot', 'validation_report') THEN 'validation'
          ELSE 'documentation'
        END
      SQL

      execute <<~SQL.squish
        UPDATE template_artifacts
        SET immutable_source = TRUE
        WHERE lineage_kind = 'source'
      SQL
    end
end
