class ResumePhotoSelection < ApplicationRecord
  SLOT_NAMES = %w[headshot].freeze

  belongs_to :resume
  belongs_to :template
  belongs_to :photo_asset

  enum :status,
       {
         active: "active",
         archived: "archived"
       },
       validate: true

  validates :slot_name, presence: true, inclusion: { in: SLOT_NAMES }
  validates :slot_name, uniqueness: { scope: %i[resume_id template_id] }
  validate :photo_asset_belongs_to_resume_user

  scope :active, -> { where(status: "active") }
  scope :for_slot, ->(slot_name) { where(slot_name: slot_name.to_s) }

  private
    def photo_asset_belongs_to_resume_user
      return if photo_asset.blank? || resume.blank?
      return if photo_asset.photo_profile.user_id == resume.user_id

      errors.add(:photo_asset, "must belong to the same user as the resume")
    end
end
