class ReferenceCaptureStep < ApplicationRecord
  belongs_to :reference_capture_run
  belongs_to :reference_capture_profile

  has_many :reference_gap_reports, dependent: :destroy
  has_one_attached :screenshot

  enum :source,
       {
         external: "external",
         internal: "internal"
       },
       validate: true

  enum :capture_status,
       {
         captured: "captured",
         blocked: "blocked",
         skipped: "skipped",
         missing: "missing"
       },
       validate: true

  before_validation :normalize_payloads

  validates :flow_key, :step_key, :sequence, :source, :capture_status, presence: true

  def comparison_status
    comparison.fetch("status", "unmapped")
  end

  def mapped_internal_step_key
    comparison["mapped_internal_step_key"]
  end

  private
    def normalize_payloads
      self.form_payload = normalize_payload(form_payload)
      self.ui_inventory = normalize_payload(ui_inventory)
      self.interaction_inventory = normalize_payload(interaction_inventory)
      self.comparison = normalize_payload(comparison)
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
