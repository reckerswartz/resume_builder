class JobLog < ApplicationRecord
  enum :status,
       {
         queued: "queued",
         running: "running",
         succeeded: "succeeded",
         failed: "failed"
       },
       validate: true

  scope :recent, -> { order(created_at: :desc) }

  before_validation :normalize_payloads

  validates :job_type, :queue_name, :status, presence: true

  def duration_seconds
    return if duration_ms.blank?

    duration_ms / 1000.0
  end

  private
    def normalize_payloads
      self.input = normalize_payload(input)
      self.output = normalize_payload(output)
      self.error_details = normalize_payload(error_details)
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
