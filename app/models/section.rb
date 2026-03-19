class Section < ApplicationRecord
  belongs_to :resume

  has_many :entries, -> { order(position: :asc, created_at: :asc) }, dependent: :destroy, inverse_of: :section

  enum :section_type,
       {
         education: "education",
         experience: "experience",
         skills: "skills",
         projects: "projects"
       },
       validate: true

  before_validation :assign_position, on: :create
  before_validation :default_title
  before_validation :normalize_settings

  validates :title, presence: true

  def ordered_entries
    entries
  end

  private
    def assign_position
      return if resume.blank? || position.to_i.positive?

      max_position = resume.sections.where.not(id: id).maximum(:position)
      self.position = max_position.nil? ? 0 : max_position + 1
    end

    def default_title
      self.title = section_type.to_s.titleize if title.blank? && section_type.present?
    end

    def normalize_settings
      self.settings = (settings || {}).deep_stringify_keys
    end
end
