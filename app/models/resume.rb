class Resume < ApplicationRecord
  BOOLEAN_TYPE = ActiveModel::Type::Boolean.new

  belongs_to :template
  belongs_to :user

  has_one_attached :pdf_export
  has_many :llm_interactions, dependent: :destroy
  has_many :sections, -> { order(position: :asc, created_at: :asc) }, dependent: :destroy, inverse_of: :resume

  validates :slug, presence: true, uniqueness: { scope: :user_id }
  validates :title, presence: true

  before_validation :assign_template
  before_validation :normalize_json_attributes
  before_validation :normalize_slug

  def contact_field(key)
    contact_details.fetch(key.to_s, "")
  end

  def ordered_sections
    sections
  end

  private
    def assign_template
      self.template ||= Template.default!
    end

    def normalize_json_attributes
      self.contact_details = (contact_details || {}).deep_stringify_keys
      self.settings = (settings || {}).deep_stringify_keys
      settings["show_contact_icons"] = BOOLEAN_TYPE.cast(settings["show_contact_icons"]) if settings.key?("show_contact_icons")
    end

    def normalize_slug
      source = slug.presence || title
      self.slug = source.to_s.parameterize.presence || SecureRandom.hex(4)
    end
end
