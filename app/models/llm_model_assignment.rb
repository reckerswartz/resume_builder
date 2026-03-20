class LlmModelAssignment < ApplicationRecord
  ROLES = %w[
    text_generation
    text_verification
    vision_generation
    vision_verification
  ].freeze

  GENERATION_ROLES = %w[text_generation vision_generation].freeze

  belongs_to :llm_model

  enum :role, ROLES.index_with { |role| role }, validate: true

  scope :ordered, -> { order(:position, :created_at) }
  scope :for_role, ->(role) { where(role: role.to_s).ordered }

  validates :role, presence: true, uniqueness: { scope: :llm_model_id }
  validates :position, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validate :llm_model_supports_selected_role

  def self.model_ids_by_role
    ROLES.index_with do |role|
      for_role(role).pluck(:llm_model_id)
    end
  end

  def self.ready_models_for(role)
    for_role(role)
      .includes(llm_model: :llm_provider)
      .map(&:llm_model)
      .select do |llm_model|
        llm_model.active? && llm_model.llm_provider.configured_for_requests?
      end
  end

  def self.available_for?(role)
    ready_models_for(role).any?
  end

  private
    def llm_model_supports_selected_role
      return if llm_model.blank? || role.blank?
      return if llm_model.supports_role?(role)

      errors.add(:llm_model, "does not support #{role.humanize.downcase}")
    end
end
