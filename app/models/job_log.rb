class JobLog < ApplicationRecord
  ADMIN_SORTS = {
    "job_type" => ->(direction) { { job_type: direction, created_at: :desc } },
    "queue_name" => ->(direction) { { queue_name: direction, created_at: :desc } },
    "status" => ->(direction) { { status: direction, created_at: :desc } },
    "created_at" => ->(direction) { { created_at: direction, id: :desc } }
  }.freeze

  enum :status,
       {
         queued: "queued",
         running: "running",
         succeeded: "succeeded",
         failed: "failed"
       },
       validate: true

  scope :recent, -> { order(created_at: :desc) }
  scope :resume_exports, -> { where(job_type: "ResumeExportJob") }
  scope :for_resume_export, ->(resume_id) { resume_exports.where("job_logs.input #>> '{arguments,0}' = ?", resume_id.to_s).recent }
  scope :completed, -> { where(status: %w[succeeded failed]) }
  scope :with_status, ->(status) { status.present? ? where(status: status) : all }
  scope :matching_query, ->(query) do
    next all if query.blank?

    term = "%#{ActiveRecord::Base.sanitize_sql_like(query.to_s.strip)}%"
    where("job_logs.job_type ILIKE :term OR job_logs.queue_name ILIKE :term OR job_logs.active_job_id ILIKE :term", term: term)
  end
  scope :with_status_filter, ->(value) do
    statuses.key?(value) ? where(status: value) : all
  end

  before_validation :normalize_payloads
  after_commit :broadcast_resume_export_status, if: :resume_export?

  validates :job_type, :queue_name, :status, presence: true

  def self.admin_sort_column(value)
    ADMIN_SORTS.key?(value) ? value : "created_at"
  end

  def self.sorted_for_admin(sort, direction)
    order(ADMIN_SORTS.fetch(admin_sort_column(sort)).call(direction.to_sym))
  end

  def duration_seconds
    return if duration_ms.blank?

    duration_ms / 1000.0
  end

  def completed?
    succeeded? || failed?
  end

  def stale?(reference_time: Time.current, threshold: 15.minutes)
    running? && started_at.present? && started_at <= reference_time - threshold
  end

  def resume_export?
    job_type == "ResumeExportJob"
  end

  def resume_id
    output["resume_id"] || input["resume_id"] || Array(input["arguments"]).first
  end

  private
    def broadcast_resume_export_status
      resume = Resume.find_by(id: resume_id)
      return unless resume

      Resumes::ExportStatusBroadcaster.new(resume: resume).call
    end

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
