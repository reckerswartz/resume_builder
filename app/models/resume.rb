class Resume < ApplicationRecord
  BOOLEAN_TYPE = ActiveModel::Type::Boolean.new
  SOURCE_MODES = %w[scratch paste upload].freeze
  EXPERIENCE_LEVELS = %w[no_experience less_than_3_years three_to_five_years five_to_ten_years ten_plus_years].freeze
  STUDENT_STATUSES = %w[student not_student].freeze
  PERSONAL_DETAIL_FIELDS = %w[date_of_birth nationality marital_status visa_status].freeze
  HEADSHOT_CONTENT_TYPES = %w[image/jpeg image/png image/webp].freeze
  MAX_HEADSHOT_SIZE = 3.megabytes
  CONTACT_STRIP_FIELDS = %w[first_name surname phone city country pin_code website linkedin driving_licence].freeze
  PAGE_SIZES = %w[A4 Letter].freeze
  DEFAULT_PAGE_SIZE = "A4".freeze

  belongs_to :template
  belongs_to :user
  belongs_to :photo_profile, optional: true

  has_one_attached :pdf_export
  has_one_attached :source_document
  has_one_attached :headshot
  has_many :llm_interactions, dependent: :destroy
  has_many :resume_photo_selections, dependent: :destroy
  has_many :sections, -> { order(position: :asc, created_at: :asc) }, dependent: :destroy, inverse_of: :resume

  validates :slug, presence: true, uniqueness: { scope: :user_id }
  validates :source_mode, inclusion: { in: SOURCE_MODES }
  validates :title, presence: true
  validate :headshot_content_type
  validate :headshot_file_size
  validate :photo_profile_belongs_to_user

  before_validation :assign_template
  before_validation :normalize_json_attributes
  before_validation :normalize_source_fields
  before_validation :normalize_slug

  def contact_field(key)
    case key.to_s
    when "full_name"
      stored_contact_field("full_name").presence || derived_full_name
    when "first_name"
      stored_contact_field("first_name").presence || parsed_full_name.fetch(:first_name)
    when "surname"
      stored_contact_field("surname").presence || parsed_full_name.fetch(:surname)
    when "location"
      stored_contact_field("location").presence || derived_location
    else
      stored_contact_field(key)
    end
  end

  def ordered_sections
    sections
  end

  def latest_export_job_log
    JobLog.for_resume_export(id).first
  end

  def export_state
    export_job_log = latest_export_job_log

    return export_job_log.status if export_job_log&.queued? || export_job_log&.running? || export_job_log&.failed?
    return "ready" if pdf_export.attached?

    "draft"
  end

  def accent_color
    ResumeTemplates::Catalog.normalized_accent_color((settings || {})["accent_color"], fallback: render_layout_config.fetch("accent_color"))
  end

  def font_family
    ResumeTemplates::Catalog.normalized_font_family((settings || {})["font_family"], fallback: render_layout_config.fetch("font_family"))
  end

  def font_scale
    ResumeTemplates::Catalog.normalized_font_scale((settings || {})["font_scale"], fallback: render_layout_config.fetch("font_scale"))
  end

  def density
    ResumeTemplates::Catalog.normalized_density((settings || {})["density"], fallback: render_layout_config.fetch("density"))
  end

  def section_spacing
    ResumeTemplates::Catalog.normalized_section_spacing((settings || {})["section_spacing"], fallback: render_layout_config.fetch("section_spacing"))
  end

  def paragraph_spacing
    ResumeTemplates::Catalog.normalized_paragraph_spacing((settings || {})["paragraph_spacing"], fallback: render_layout_config.fetch("paragraph_spacing"))
  end

  def line_spacing
    ResumeTemplates::Catalog.normalized_line_spacing((settings || {})["line_spacing"], fallback: render_layout_config.fetch("line_spacing"))
  end

  def page_size
    (settings || {})["page_size"].to_s.presence_in(PAGE_SIZES) || DEFAULT_PAGE_SIZE
  end

  def show_contact_icons?
    BOOLEAN_TYPE.cast((settings || {}).fetch("show_contact_icons", true))
  end

  def hidden_section_types
    normalize_hidden_sections((settings || {})["hidden_sections"])
  end

  def source_step_completed?
    case source_mode
    when "paste"
      source_text.present?
    when "upload"
      source_document.attached?
    else
      true
    end
  end

  def experience_level
    stored_intake_field("experience_level").to_s.presence_in(EXPERIENCE_LEVELS).to_s
  end

  def student_status
    return "" unless experience_level == "less_than_3_years"

    stored_intake_field("student_status").to_s.presence_in(STUDENT_STATUSES).to_s
  end

  def personal_detail_field(key)
    personal_details.fetch(key.to_s, "")
  end

  def personal_details
    normalize_personal_details_payload(self[:personal_details])
  end

  def personal_details=(value)
    self[:personal_details] = normalize_personal_details_payload(value)
  end

  def selected_headshot_photo_asset
    selected_photo_asset_for("headshot")
  end

  def selected_photo_asset_for(slot_name, template: self.template)
    template_identifier = template&.id || template_id
    selection_scope = resume_photo_selections.active.for_slot(slot_name)
    selection = template_identifier.present? ? selection_scope.find_by(template_id: template_identifier) : nil

    selection&.photo_asset || fallback_photo_asset_for(slot_name)
  end

  def personal_details_step_completed?
    return true if selected_headshot_photo_asset.present?
    return true if headshot.attached?

    PERSONAL_DETAIL_FIELDS.any? { |field| personal_detail_field(field).present? } ||
      %w[website linkedin driving_licence].any? { |field| contact_field(field).present? }
  end

  private

  def assign_template
    self.template ||= Template.default!
  end

  def normalize_json_attributes
    self.contact_details = (contact_details || {}).deep_stringify_keys
    normalize_contact_details
    self.personal_details = normalized_personal_details
    self.settings = (settings || {}).deep_stringify_keys
    settings["show_contact_icons"] = BOOLEAN_TYPE.cast(settings["show_contact_icons"]) if settings.key?("show_contact_icons")
    settings["page_size"] = page_size if settings.key?("page_size")
    normalized_font_family_setting if settings.key?("font_family")
    normalized_font_scale_setting if settings.key?("font_scale")
    normalized_density_setting if settings.key?("density")
    normalized_section_spacing_setting if settings.key?("section_spacing")
    normalized_paragraph_spacing_setting if settings.key?("paragraph_spacing")
    normalized_line_spacing_setting if settings.key?("line_spacing")
    settings["hidden_sections"] = normalize_hidden_sections(settings["hidden_sections"]) if settings.key?("hidden_sections")
    self.intake_details = normalized_intake_details
  end

  def normalize_source_fields
    self.source_mode = source_mode.to_s.presence_in(SOURCE_MODES) || "scratch"
    self.source_text = source_text.to_s
  end

  def normalize_slug
    source = slug.presence || title
    base_slug = source.to_s.parameterize.presence || SecureRandom.hex(4)
    self.slug = unique_slug(base_slug)
  end

  def unique_slug(base_slug)
    return base_slug if user_id.blank?

    candidate = base_slug
    suffix = 2

    while slug_taken_for_user?(candidate)
      candidate = "#{base_slug}-#{suffix}"
      suffix += 1
    end

    candidate
  end

  def slug_taken_for_user?(candidate)
    relation = self.class.where(user_id:, slug: candidate)
    relation = relation.where.not(id:) if persisted?
    relation.exists?
  end

  def normalize_contact_details
    normalized_contact_details = contact_details.deep_stringify_keys

    CONTACT_STRIP_FIELDS.each do |field|
      normalized_contact_details[field] = stored_contact_field(field).to_s.strip
    end

    normalized_contact_details["full_name"] = (derived_full_name.presence || stored_contact_field("full_name")).to_s.strip
    normalized_contact_details["location"] = (derived_location.presence || stored_contact_field("location")).to_s.strip

    self.contact_details = normalized_contact_details
  end

  def normalized_intake_details
    raw_details = (intake_details || {}).deep_stringify_keys
    normalized_details = {}

    if raw_details.key?("experience_level")
      normalized_details["experience_level"] = raw_details["experience_level"].to_s.presence_in(EXPERIENCE_LEVELS).to_s
      normalized_details["student_status"] = ""
    end

    if raw_details.key?("student_status")
      normalized_details["student_status"] = if normalized_details["experience_level"] == "less_than_3_years"
        raw_details["student_status"].to_s.presence_in(STUDENT_STATUSES).to_s
      else
        ""
      end
    end

    normalized_details
  end

  def normalized_personal_details
    normalize_personal_details_payload(self[:personal_details])
  end

  def parsed_full_name
    first_name, surname = stored_contact_field("full_name").to_s.squish.split(" ", 2)

    {
      first_name: first_name.to_s,
      surname: surname.to_s
    }
  end

  def derived_full_name
    [ stored_contact_field("first_name"), stored_contact_field("surname") ].reject(&:blank?).join(" ")
  end

  def derived_location
    location_line = [ stored_contact_field("city"), stored_contact_field("country") ].reject(&:blank?).join(", ")
    [ location_line, stored_contact_field("pin_code") ].reject(&:blank?).join(" ")
  end

  def stored_contact_field(key)
    contact_details.fetch(key.to_s, "")
  end

  def stored_intake_field(key)
    intake_details.fetch(key.to_s, "")
  end

  def normalize_personal_details_payload(value)
    raw_details = (value || {}).deep_stringify_keys

    PERSONAL_DETAIL_FIELDS.index_with do |field|
      raw_details[field].to_s.strip
    end
  end

  def normalize_hidden_sections(value)
    Array(value).map(&:to_s).select { |section_type| ResumeBuilder::SectionRegistry.types.include?(section_type) }.uniq
  end

  def normalized_font_family_setting
    candidate = settings["font_family"].to_s
    return settings.delete("font_family") if candidate.blank?

    settings["font_family"] = ResumeTemplates::Catalog.normalized_font_family(candidate, fallback: render_layout_config.fetch("font_family"))
  end

  def normalized_font_scale_setting
    candidate = settings["font_scale"].to_s
    return settings.delete("font_scale") if candidate.blank?

    settings["font_scale"] = ResumeTemplates::Catalog.normalized_font_scale(candidate, fallback: render_layout_config.fetch("font_scale"))
  end

  def normalized_density_setting
    candidate = settings["density"].to_s
    return settings.delete("density") if candidate.blank?

    settings["density"] = ResumeTemplates::Catalog.normalized_density(candidate, fallback: render_layout_config.fetch("density"))
  end

  def normalized_section_spacing_setting
    candidate = settings["section_spacing"].to_s
    return settings.delete("section_spacing") if candidate.blank?

    settings["section_spacing"] = ResumeTemplates::Catalog.normalized_section_spacing(candidate, fallback: render_layout_config.fetch("section_spacing"))
  end

  def normalized_paragraph_spacing_setting
    candidate = settings["paragraph_spacing"].to_s
    return settings.delete("paragraph_spacing") if candidate.blank?

    settings["paragraph_spacing"] = ResumeTemplates::Catalog.normalized_paragraph_spacing(candidate, fallback: render_layout_config.fetch("paragraph_spacing"))
  end

  def normalized_line_spacing_setting
    candidate = settings["line_spacing"].to_s
    return settings.delete("line_spacing") if candidate.blank?

    settings["line_spacing"] = ResumeTemplates::Catalog.normalized_line_spacing(candidate, fallback: render_layout_config.fetch("line_spacing"))
  end

  def render_layout_config
    template&.render_layout_config || ResumeTemplates::Catalog.default_layout_config
  end

  def fallback_photo_asset_for(slot_name)
    return unless slot_name.to_s == "headshot"

    PhotoProfile.find_by(id: photo_profile_id)&.preferred_headshot_asset
  end

  def photo_profile_belongs_to_user
    return if photo_profile.blank?
    return if photo_profile.user_id == user_id

    errors.add(:photo_profile, "must belong to the same user")
  end

  def headshot_content_type
    return unless headshot.attached?
    return if HEADSHOT_CONTENT_TYPES.include?(headshot.blob.content_type)

    errors.add(:headshot, "must be a JPG, PNG, or WebP image")
  end

  def headshot_file_size
    return unless headshot.attached?
    return if headshot.blob.byte_size <= MAX_HEADSHOT_SIZE

    errors.add(:headshot, "must be smaller than 3 MB")
  end
end
