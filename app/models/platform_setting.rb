class PlatformSetting < ApplicationRecord
  BOOLEAN_TYPE = ActiveModel::Type::Boolean.new

  before_validation :normalize_payloads

  validates :name, presence: true, uniqueness: true

  def self.current
    find_or_create_by!(name: "global")
  end

  def feature_enabled?(key)
    feature_flags.fetch(key.to_s, false)
  end

  def set_feature(key, value)
    self.feature_flags = feature_flags.merge(key.to_s => ActiveModel::Type::Boolean.new.cast(value))
  end

  private
    def normalize_payloads
      self.feature_flags = (feature_flags || {}).deep_stringify_keys.transform_values { |value| BOOLEAN_TYPE.cast(value) }
      self.preferences = (preferences || {}).deep_stringify_keys
    end
end
