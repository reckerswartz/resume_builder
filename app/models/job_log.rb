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
      self.input = (input || {}).deep_stringify_keys
      self.output = (output || {}).deep_stringify_keys
      self.error_details = (error_details || {}).deep_stringify_keys
    end
end
