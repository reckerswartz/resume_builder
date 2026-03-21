class TemplateValidationRun < ApplicationRecord
  belongs_to :template
  belongs_to :template_implementation, optional: true
  belongs_to :reference_artifact, class_name: "TemplateArtifact", optional: true

  enum :validation_type,
       {
         preview_html: "preview_html",
         pdf_export: "pdf_export",
         pixel_compare: "pixel_compare",
         manual_review: "manual_review",
         seed_promotion: "seed_promotion"
       },
       validate: true

  enum :status,
       {
         pending: "pending",
         passed: "passed",
         failed: "failed",
         needs_review: "needs_review"
       },
       validate: true

  before_validation :normalize_payloads
  before_validation :assign_identifier

  validates :identifier, presence: true, uniqueness: true
  validates :validation_type, :status, presence: true

  scope :recent, -> { order(validated_at: :desc, created_at: :desc) }
  scope :successful, -> { where(status: "passed") }

  def successful?
    passed?
  end

  private
    def normalize_payloads
      self.metrics = (metrics || {}).deep_stringify_keys
      self.metadata = (metadata || {}).deep_stringify_keys
    end

    def assign_identifier
      return if identifier.present?

      self.identifier = normalize_identifier_parts(
        template.slug,
        validation_type.presence || "validation",
        template_implementation&.identifier.presence || reference_artifact&.identifier.presence || "run",
        Time.current.to_i,
        SecureRandom.hex(4)
      )
    end

    def normalize_identifier_parts(*parts)
      parts.compact.map { |part| part.to_s.tr("_", "-") }.join("-").parameterize(separator: "-")
    end
end
