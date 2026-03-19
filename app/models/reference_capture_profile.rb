class ReferenceCaptureProfile < ApplicationRecord
  belongs_to :reference_capture_run

  has_many :reference_capture_steps, dependent: :destroy
  has_many :reference_gap_reports, dependent: :destroy

  before_validation :normalize_seed_data
  before_validation :normalize_slug

  validates :name, :slug, :persona_type, :experience_level, :target_role, presence: true

  private
    def normalize_seed_data
      self.seed_data = (seed_data || {}).deep_stringify_keys
    end

    def normalize_slug
      self.slug = (slug.presence || name).to_s.parameterize
    end
end
