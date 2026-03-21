class TemplateImplementation < ApplicationRecord
  belongs_to :template
  belongs_to :source_artifact, class_name: "TemplateArtifact", optional: true

  has_many :template_validation_runs, dependent: :nullify

  enum :status,
       {
         draft: "draft",
         validated: "validated",
         stable: "stable",
         seeded: "seeded",
         archived: "archived"
       },
       validate: true

  before_validation :normalize_payloads
  before_validation :assign_renderer_family
  before_validation :assign_identifier

  validates :identifier, presence: true, uniqueness: true
  validates :name, :renderer_family, :status, presence: true

  scope :render_ready, -> { where(status: %w[validated stable seeded]) }
  scope :most_recent_first, -> { order(Arel.sql("COALESCE(seeded_at, validated_at, created_at) DESC")) }

  def effective_render_profile
    ResumeTemplates::Catalog.normalize_layout_config(
      render_profile,
      fallback_family: renderer_family.presence || template.slug
    )
  end

  def render_ready?
    validated? || stable? || seeded?
  end

  def seed_ready?
    stable? || seeded?
  end

  private
    def normalize_payloads
      self.render_profile = (render_profile || {}).deep_stringify_keys
      self.metadata = (metadata || {}).deep_stringify_keys
    end

    def assign_renderer_family
      self.renderer_family = renderer_family.presence || render_profile["family"].presence || template.layout_family
    end

    def assign_identifier
      return if identifier.present?

      self.identifier = normalize_identifier_parts(
        template.slug,
        renderer_family.presence || template.layout_family,
        name.presence || "implementation"
      )
    end

    def normalize_identifier_parts(*parts)
      parts.compact.map { |part| part.to_s.tr("_", "-") }.join("-").parameterize(separator: "-")
    end
end
