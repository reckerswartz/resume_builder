class Entry < ApplicationRecord
  belongs_to :section

  before_validation :assign_position, on: :create
  before_validation :normalize_content

  validates :content, presence: true

  def highlights
    Array(content["highlights"])
  end

  private
    def assign_position
      return if section.blank? || position.to_i.positive?

      max_position = section.entries.where.not(id: id).maximum(:position)
      self.position = max_position.nil? ? 0 : max_position + 1
    end

    def normalize_content
      self.content = (content || {}).deep_stringify_keys
      self.content["highlights"] = Array(content["highlights"]).reject(&:blank?) if content.key?("highlights")
    end
end
