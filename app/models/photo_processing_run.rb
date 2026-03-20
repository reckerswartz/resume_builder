class PhotoProcessingRun < ApplicationRecord
  belongs_to :photo_profile
  belongs_to :resume, optional: true
  belongs_to :template, optional: true
  belongs_to :job_log, optional: true

  enum :workflow_type,
       {
         normalize: "normalize",
         background_remove: "background_remove",
         enhance: "enhance",
         generate_for_template: "generate_for_template",
         verify_candidate: "verify_candidate"
       },
       validate: true

  enum :status,
       {
         queued: "queued",
         running: "running",
         succeeded: "succeeded",
         failed: "failed",
         cancelled: "cancelled"
       },
       validate: true

  before_validation :normalize_payloads

  validates :workflow_type, :status, presence: true

  scope :recent, -> { order(created_at: :desc) }

  def mark_running!(job_log: nil, started_at: Time.current)
    update!(status: :running, job_log: job_log || self.job_log, started_at:, finished_at: nil)
  end

  def mark_succeeded!(output_asset_ids: nil, response_payload: nil, next_step_guidance: nil, metadata: nil, finished_at: Time.current)
    update!(
      status: :succeeded,
      output_asset_ids: normalize_array_payload(output_asset_ids || self.output_asset_ids),
      response_payload: normalize_hash_payload(response_payload || self.response_payload),
      next_step_guidance: next_step_guidance || self.next_step_guidance,
      metadata: normalize_hash_payload((self.metadata || {}).merge(metadata || {})),
      error_summary: nil,
      finished_at:
    )
  end

  def mark_failed!(error_summary:, response_payload: nil, metadata: nil, finished_at: Time.current)
    update!(
      status: :failed,
      error_summary: error_summary,
      response_payload: normalize_hash_payload(response_payload || self.response_payload),
      metadata: normalize_hash_payload((self.metadata || {}).merge(metadata || {})),
      finished_at:
    )
  end

  private
    def normalize_payloads
      self.selected_model_ids = normalize_array_payload(selected_model_ids)
      self.input_asset_ids = normalize_array_payload(input_asset_ids)
      self.output_asset_ids = normalize_array_payload(output_asset_ids)
      self.request_payload = normalize_hash_payload(request_payload)
      self.response_payload = normalize_hash_payload(response_payload)
      self.metadata = normalize_hash_payload(metadata)
    end

    def normalize_hash_payload(value)
      (value || {}).deep_stringify_keys
    end

    def normalize_array_payload(value)
      Array(value).map do |item|
        item.respond_to?(:to_h) ? item.to_h.deep_stringify_keys : item
      end
    end
end
