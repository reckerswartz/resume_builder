class PhotoAsset < ApplicationRecord
  IMAGE_CONTENT_TYPES = %w[image/jpeg image/png image/webp].freeze
  MAX_FILE_SIZE = 10.megabytes
  SELECTION_KIND_ORDER = {
    "enhanced" => 0,
    "generated" => 1,
    "variation" => 2,
    "cutout" => 3,
    "normalized" => 4,
    "source" => 5,
    "template_composite" => 6,
    "rejected" => 7
  }.freeze

  belongs_to :photo_profile
  belongs_to :source_asset, class_name: "PhotoAsset", optional: true

  has_one_attached :file
  has_many :derived_assets, class_name: "PhotoAsset", foreign_key: :source_asset_id, dependent: :nullify, inverse_of: :source_asset
  has_many :resume_photo_selections, dependent: :destroy

  enum :asset_kind,
       {
         source: "source",
         normalized: "normalized",
         cutout: "cutout",
         enhanced: "enhanced",
         generated: "generated",
         variation: "variation",
         template_composite: "template_composite",
         rejected: "rejected"
       },
       validate: true

  enum :status,
       {
         uploaded: "uploaded",
         ready: "ready",
         archived: "archived",
         failed: "failed"
       },
       validate: true

  before_validation :normalize_metadata

  validates :asset_kind, :status, presence: true
  validate :source_asset_belongs_to_profile
  validate :file_presence
  validate :file_content_type
  validate :file_size

  scope :ready_for_library, -> { where(status: "ready", asset_kind: SELECTION_KIND_ORDER.keys) }
  scope :latest_first, -> { order(updated_at: :desc, created_at: :desc) }

  def checksum
    metadata["checksum"].presence || file.blob&.checksum
  end

  def content_type
    metadata["content_type"].presence || file.blob&.content_type.to_s
  end

  def byte_size
    metadata["byte_size"].presence || file.blob&.byte_size
  end

  def width
    metadata["width"]
  end

  def height
    metadata["height"]
  end

  def ready_for_selection?
    ready? && !rejected?
  end

  def selection_priority
    SELECTION_KIND_ORDER.fetch(asset_kind, SELECTION_KIND_ORDER.length)
  end

  def display_name
    metadata["display_name"].presence || file.filename.to_s.presence || "Photo asset ##{id}"
  end

  def attach_metadata!(extra_metadata = {})
    update!(metadata: metadata.merge(extra_metadata.deep_stringify_keys).compact_blank)
  end

  private
    def normalize_metadata
      self.metadata = (metadata || {}).deep_stringify_keys
    end

    def source_asset_belongs_to_profile
      return if source_asset.blank?
      return if source_asset.photo_profile_id == photo_profile_id

      errors.add(:source_asset, "must belong to the same photo profile")
    end

    def file_presence
      errors.add(:file, "must be attached") unless file.attached?
    end

    def file_content_type
      return unless file.attached?
      return if IMAGE_CONTENT_TYPES.include?(file.blob.content_type)

      errors.add(:file, "must be a JPG, PNG, or WebP image")
    end

    def file_size
      return unless file.attached?
      return if file.blob.byte_size <= MAX_FILE_SIZE

      errors.add(:file, "must be smaller than 10 MB")
    end
end
