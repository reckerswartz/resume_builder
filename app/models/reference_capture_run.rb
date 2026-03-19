class ReferenceCaptureRun < ApplicationRecord
  has_many :reference_capture_profiles, dependent: :destroy
  has_many :reference_capture_steps, dependent: :destroy
  has_many :reference_gap_reports, dependent: :destroy

  enum :status,
       {
         queued: "queued",
         running: "running",
         completed: "completed",
         failed: "failed"
       },
       validate: true

  before_validation :normalize_summary

  validates :source_name, :source_base_url, :status, presence: true

  def duration_seconds
    return if started_at.blank? || finished_at.blank?

    finished_at - started_at
  end

  def external_steps
    reference_capture_steps.external.order(:sequence, :created_at)
  end

  def internal_steps
    reference_capture_steps.internal.order(:sequence, :created_at)
  end

  def latest_progress_update
    Array(summary["progress_updates"]).last
  end

  private
    def normalize_summary
      self.summary = (summary || {}).deep_stringify_keys
    end
end
