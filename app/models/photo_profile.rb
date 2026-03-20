class PhotoProfile < ApplicationRecord
  DEFAULT_NAME_SUFFIX = "Photo Library".freeze

  belongs_to :user
  belongs_to :selected_source_photo_asset, class_name: "PhotoAsset", optional: true

  has_many :photo_assets, -> { order(updated_at: :desc, created_at: :desc) }, dependent: :destroy, inverse_of: :photo_profile
  has_many :photo_processing_runs, -> { order(created_at: :desc) }, dependent: :destroy, inverse_of: :photo_profile
  has_many :resumes, dependent: :nullify

  enum :status,
       {
         draft: "draft",
         active: "active",
         archived: "archived"
       },
       validate: true

  before_validation :normalize_payloads

  validates :name, presence: true
  validate :selected_source_photo_asset_belongs_to_profile

  def self.default_for(user)
    user.photo_profiles.order(updated_at: :desc).first || user.photo_profiles.create!(
      name: "#{user.display_name} #{DEFAULT_NAME_SUFFIX}",
      status: :active
    )
  end

  def preferred_headshot_asset
    photo_assets
      .select(&:ready_for_selection?)
      .sort_by { |asset| [ asset.selection_priority, -asset.updated_at.to_i ] }
      .first || selected_source_photo_asset
  end

  private
    def normalize_payloads
      self.preferences = (preferences || {}).deep_stringify_keys
      self.status ||= "draft"
    end

    def selected_source_photo_asset_belongs_to_profile
      return if selected_source_photo_asset.blank?
      return if selected_source_photo_asset.photo_profile_id == id

      errors.add(:selected_source_photo_asset, "must belong to the same photo profile")
    end
end
