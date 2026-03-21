class BackfillPhotoLibraryFeatureFlags < ActiveRecord::Migration[8.1]
  class PlatformSettingRecord < ActiveRecord::Base
    self.table_name = "platform_settings"
  end

  def up
    PlatformSettingRecord.find_each do |platform_setting|
      feature_flags = (platform_setting.feature_flags || {}).deep_stringify_keys
      updated_feature_flags = feature_flags.dup

      updated_feature_flags["photo_processing"] = !Rails.env.production? unless feature_flags.key?("photo_processing")
      updated_feature_flags["resume_image_generation"] = false unless feature_flags.key?("resume_image_generation")

      next if updated_feature_flags == feature_flags

      platform_setting.update_columns(feature_flags: updated_feature_flags, updated_at: Time.current)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
