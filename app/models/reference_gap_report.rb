class ReferenceGapReport < ApplicationRecord
  belongs_to :reference_capture_run
  belongs_to :reference_capture_profile
  belongs_to :reference_capture_step

  enum :severity,
       {
         low: "low",
         medium: "medium",
         high: "high",
         critical: "critical"
       },
       validate: true

  enum :status,
       {
         open: "open",
         in_progress: "in_progress",
         resolved: "resolved",
         blocked: "blocked"
       },
       validate: true

  before_validation :normalize_payloads

  validates :category, :severity, :status, presence: true

  private
    def normalize_payloads
      self.evidence = normalize_payload(evidence)
      self.recommended_work = normalize_payload(recommended_work)
    end

    def normalize_payload(value)
      case value
      when nil
        {}
      when Hash
        value.deep_stringify_keys
      else
        { "value" => value.as_json }
      end
    end
end
