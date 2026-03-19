class Template < ApplicationRecord
  has_many :resumes, dependent: :restrict_with_exception

  scope :active, -> { where(active: true) }

  before_validation :normalize_slug
  before_validation :normalize_layout_config

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  def self.default!
    active.order(:created_at).first || order(:created_at).first || raise(ActiveRecord::RecordNotFound, "No templates configured")
  end

  private
    def normalize_slug
      self.slug = (slug.presence || name).to_s.parameterize
    end

    def normalize_layout_config
      self.layout_config = (layout_config || {}).deep_stringify_keys
    end
end
