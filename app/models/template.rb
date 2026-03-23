class Template < ApplicationRecord
  has_many :resumes, dependent: :restrict_with_exception
  has_many :template_artifacts, dependent: :destroy
  has_many :template_implementations, dependent: :destroy
  has_many :template_validation_runs, dependent: :destroy

  ADMIN_SORTS = {
    "name" => ->(direction) { { name: direction, slug: :asc } },
    "slug" => ->(direction) { { slug: direction, name: :asc } },
    "active" => ->(direction) { { active: direction, name: :asc } },
    "updated_at" => ->(direction) { { updated_at: direction, name: :asc } }
  }.freeze

  scope :active, -> { where(active: true) }
  scope :matching_query, ->(query) do
    next all if query.blank?

    term = "%#{ActiveRecord::Base.sanitize_sql_like(query.to_s.strip)}%"
    where("templates.name ILIKE :term OR templates.slug ILIKE :term OR templates.description ILIKE :term", term: term)
  end
  scope :with_family_filter, ->(family) do
    next all if family.blank? || family.to_s == "all"

    where("templates.layout_config ->> 'family' = ?", family.to_s)
  end
  scope :with_density_filter, ->(density) do
    next all if density.blank? || density.to_s == "all"

    where("templates.layout_config ->> 'density' = ?", density.to_s)
  end
  scope :with_column_count_filter, ->(column_count) do
    next all if column_count.blank? || column_count.to_s == "all"

    where("templates.layout_config ->> 'column_count' = ?", column_count.to_s)
  end
  scope :with_theme_tone_filter, ->(theme_tone) do
    next all if theme_tone.blank? || theme_tone.to_s == "all"

    where("templates.layout_config ->> 'theme_tone' = ?", theme_tone.to_s)
  end
  scope :with_shell_style_filter, ->(shell_style) do
    next all if shell_style.blank? || shell_style.to_s == "all"

    where("templates.layout_config ->> 'shell_style' = ?", shell_style.to_s)
  end
  scope :with_headshot_support_filter, ->(headshot_support) do
    next all if headshot_support.blank? || headshot_support.to_s == "all"

    case headshot_support.to_s
    when "yes"
      where("(templates.layout_config ->> 'supports_headshot')::boolean = true")
    when "no"
      where("(templates.layout_config ->> 'supports_headshot')::boolean IS DISTINCT FROM true")
    else
      all
    end
  end
  scope :with_active_filter, ->(status) do
    case status
    when "active"
      where(active: true)
    when "inactive"
      where(active: false)
    else
      all
    end
  end

  before_validation :normalize_slug
  before_validation :normalize_layout_config

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true

  def self.admin_sort_column(value)
    ADMIN_SORTS.key?(value) ? value : "name"
  end

  def self.sorted_for_admin(sort, direction)
    order(ADMIN_SORTS.fetch(admin_sort_column(sort)).call(direction.to_sym))
  end

  def self.default!
    active.order(:created_at).first || order(:created_at).first || raise(ActiveRecord::RecordNotFound, "No templates configured")
  end

  def self.user_visible
    active.exists? ? active : all
  end

  def normalized_layout_config
    ResumeTemplates::Catalog.normalize_layout_config(layout_config, fallback_family: layout_family_fallback)
  end

  def current_implementation
    template_implementations.render_ready.most_recent_first.first
  end

  def render_layout_config
    ResumeTemplates::RenderProfileResolver.new(template: self).call
  end

  def layout_family
    normalized_layout_config.fetch("family")
  end

  private
    def normalize_slug
      self.slug = (slug.presence || name).to_s.parameterize
    end

    def normalize_layout_config
      self.layout_config = ResumeTemplates::Catalog.normalize_layout_config(layout_config, fallback_family: layout_family_fallback)
    end

    def layout_family_fallback
      slug.presence || name.to_s.parameterize.presence
    end
end
