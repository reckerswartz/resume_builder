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
      return if position.present? || resume.blank?

      self.position = resume.sections.where.not(id: id).maximum(:position).to_i + 1
    end

    def default_title
      self.title = section_type.to_s.titleize if title.blank? && section_type.present?
    end

    def normalize_settings
      self.settings = (settings || {}).deep_stringify_keys
    end
end
