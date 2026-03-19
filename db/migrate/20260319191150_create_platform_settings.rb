class CreatePlatformSettings < ActiveRecord::Migration[8.1]
  def change
    create_table :platform_settings do |t|
      t.string :name, null: false
      t.jsonb :feature_flags, null: false, default: {}
      t.jsonb :preferences, null: false, default: {}

      t.timestamps
    end

    add_index :platform_settings, :name, unique: true
  end
end
