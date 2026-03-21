class TemplateArtifact < ApplicationRecord
  belongs_to :template

  belongs_to :parent_artifact, class_name: "TemplateArtifact", optional: true

  has_many :child_artifacts, class_name: "TemplateArtifact", foreign_key: :parent_artifact_id, dependent: :nullify
  has_many :template_implementations, foreign_key: :source_artifact_id, dependent: :nullify
  has_many :template_validation_runs, foreign_key: :reference_artifact_id, dependent: :nullify

  has_one_attached :artifact_file
  has_one_attached :reference_image

  ARTIFACT_TYPES = %w[
    source_capture
    reference_design
    reference_image
    design_note
    decision_log
    version_snapshot
    implementation_snapshot
    discrepancy_report
    validation_snapshot
    validation_report
    layout_spec
    seed_snapshot
  ].freeze

  LINEAGE_KINDS = %w[source derived validation documentation].freeze

  STATUSES = %w[active archived superseded].freeze

  scope :active, -> { where(status: "active") }
  scope :by_type, ->(type) { where(artifact_type: type) if type.present? }
  scope :source_material, -> { where(lineage_kind: "source") }
  scope :derived_material, -> { where(lineage_kind: "derived") }
  scope :validated_material, -> { where(lineage_kind: "validation") }
  scope :documentation_material, -> { where(lineage_kind: "documentation") }
  scope :immutable_sources, -> { where(immutable_source: true) }
  scope :reference_designs, -> { where(artifact_type: "reference_design") }
  scope :design_notes, -> { where(artifact_type: "design_note") }
  scope :version_snapshots, -> { where(artifact_type: "version_snapshot") }
  scope :discrepancy_reports, -> { where(artifact_type: "discrepancy_report") }
  scope :layout_specs, -> { where(artifact_type: "layout_spec") }

  before_validation :normalize_payloads
  before_validation :assign_identifier
  before_validation :assign_source_metadata
  before_validation :assign_lineage_kind

  validates :name, presence: true
  validates :identifier, presence: true, uniqueness: true
  validates :artifact_type, presence: true, inclusion: { in: ARTIFACT_TYPES }
  validates :lineage_kind, presence: true, inclusion: { in: LINEAGE_KINDS }
  validates :source_signature, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }

  def active?
    status == "active"
  end

  def archived?
    status == "archived"
  end

  def source?
    lineage_kind == "source"
  end

  def derived?
    lineage_kind == "derived"
  end

  def validation?
    lineage_kind == "validation"
  end

  def documentation?
    lineage_kind == "documentation"
  end

  def discrepancy_items
    metadata.fetch("discrepancies", [])
  end

  def pixel_status
    metadata.fetch("pixel_status", "not_started")
  end

  def reference_source_url
    source_url.presence || metadata.fetch("reference_source_url", nil)
  end

  def primary_attachment
    return artifact_file if artifact_file.attached?
    return reference_image if reference_image.attached?

    nil
  end

  def primary_attachment_metadata
    attachment = primary_attachment
    return {} unless attachment.present?

    {
      "name" => attachment.name.to_s,
      "filename" => attachment.filename.to_s,
      "content_type" => attachment.blob.content_type,
      "byte_size" => attachment.blob.byte_size,
      "checksum" => attachment.blob.checksum,
      "blob_id" => attachment.blob.id
    }
  end

  private
    def normalize_payloads
      self.metadata = (metadata || {}).deep_stringify_keys
    end

    def assign_identifier
      return if identifier.present?

      self.identifier = normalize_identifier_parts(
        template&.slug,
        artifact_type.presence || "artifact",
        name.presence,
        version_label.presence || "record"
      )
    end

    def assign_source_metadata
      self.source_url = source_url.presence || metadata["reference_source_url"].presence
      self.source_signature = source_signature.presence || normalize_identifier_parts(
        template&.slug,
        artifact_type,
        version_label.presence || "baseline",
        source_url.presence || name
      )
    end

    def assign_lineage_kind
      if lineage_kind.present? && lineage_kind != "documentation"
        self.immutable_source = true if source_lineage?
        return
      end

      self.lineage_kind = case artifact_type
      when "source_capture", "reference_design", "reference_image"
        "source"
      when "version_snapshot", "implementation_snapshot", "seed_snapshot"
        "derived"
      when "discrepancy_report", "validation_snapshot", "validation_report"
        "validation"
      else
        "documentation"
      end

      self.immutable_source = true if source_lineage?
    end

    def source_lineage?
      lineage_kind == "source"
    end

    def normalize_identifier_parts(*parts)
      parts.compact.map { |part| part.to_s.tr("_", "-") }.join("-").parameterize(separator: "-")
    end
end
