require "securerandom"

class ErrorLog < ApplicationRecord
  ADMIN_SORTS = {
    "reference_id" => ->(direction) { { reference_id: direction, occurred_at: :desc } },
    "source" => ->(direction) { { source: direction, occurred_at: :desc } },
    "error_class" => ->(direction) { { error_class: direction, occurred_at: :desc } },
    "occurred_at" => ->(direction) { { occurred_at: direction, created_at: :desc } }
  }.freeze

  enum :source,
       {
         request: "request",
         job: "job"
       },
       validate: true

  scope :recent, -> { order(occurred_at: :desc, created_at: :desc) }
  scope :matching_query, ->(query) do
    next all if query.blank?

    term = "%#{ActiveRecord::Base.sanitize_sql_like(query.to_s.strip)}%"
    where(
      "error_logs.reference_id ILIKE :term OR error_logs.error_class ILIKE :term OR error_logs.message ILIKE :term OR error_logs.context->>'request_id' ILIKE :term OR error_logs.context->>'active_job_id' ILIKE :term",
      term: term
    )
  end
  scope :with_source_filter, ->(value) do
    sources.key?(value) ? where(source: value) : all
  end

  before_validation :assign_reference_id, on: :create
  before_validation :normalize_payloads

  validates :reference_id, :source, :error_class, :message, :occurred_at, presence: true

  def self.admin_sort_column(value)
    ADMIN_SORTS.key?(value) ? value : "occurred_at"
  end

  def self.sorted_for_admin(sort, direction)
    order(ADMIN_SORTS.fetch(admin_sort_column(sort)).call(direction.to_sym))
  end

  def duration_seconds
    return if duration_ms.blank?

    duration_ms / 1000.0
  end

  private
    def assign_reference_id
      self.reference_id ||= "ERR-#{Time.current.strftime('%Y%m%d')}-#{SecureRandom.hex(4).upcase}"
    end

    def normalize_payloads
      self.context = normalize_payload(context)
      self.backtrace_lines = Array(backtrace_lines).map(&:to_s)
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
