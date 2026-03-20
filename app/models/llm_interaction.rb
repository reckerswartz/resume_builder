class LlmInteraction < ApplicationRecord
  belongs_to :llm_model, optional: true
  belongs_to :llm_provider, optional: true
  belongs_to :user
  belongs_to :resume

  enum :status,
       {
         queued: "queued",
         succeeded: "succeeded",
         failed: "failed",
         skipped: "skipped"
       },
       validate: true

  before_validation :assign_provider_from_model
  before_validation :normalize_payloads

  validates :feature_name, :status, presence: true
  validates :role, inclusion: { in: LlmModelAssignment::ROLES }, allow_blank: true

  private
    def assign_provider_from_model
      self.llm_provider ||= llm_model&.llm_provider
    end

    def normalize_payloads
      self.token_usage = (token_usage || {}).deep_stringify_keys
      self.metadata = (metadata || {}).deep_stringify_keys
    end
end
