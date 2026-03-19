class LlmInteraction < ApplicationRecord
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

  before_validation :normalize_payloads

  validates :feature_name, :status, presence: true

  private
    def normalize_payloads
      self.token_usage = (token_usage || {}).deep_stringify_keys
      self.metadata = (metadata || {}).deep_stringify_keys
    end
end
