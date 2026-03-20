class Resume < ApplicationRecord
  BOOLEAN_TYPE = ActiveModel::Type::Boolean.new
  SOURCE_MODES = %w[scratch paste upload].freeze
  EXPERIENCE_LEVELS = %w[no_experience less_than_3_years three_to_five_years five_to_ten_years ten_plus_years].freeze
  STUDENT_STATUSES = %w[student not_student].freeze
  PERSONAL_DETAIL_FIELDS = %w[date_of_birth nationality marital_status visa_status].freeze

  belongs_to :template
  belongs_to :user

  has_one_attached :pdf_export
  has_one_attached :source_document
  has_many :llm_interactions, dependent: :destroy
  has_many :sections, -> { order(position: :asc, created_at: :asc) }, dependent: :destroy, inverse_of: :resume

  validates :slug, presence: true, uniqueness: { scope: :user_id }
  validates :source_mode, inclusion: { in: SOURCE_MODES }
  validates :title, presence: true

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

  def personal_details_step_completed?
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

    normalized_contact_details["first_name"] = stored_contact_field("first_name").to_s.strip
    normalized_contact_details["surname"] = stored_contact_field("surname").to_s.strip
    normalized_contact_details["phone"] = stored_contact_field("phone").to_s.strip
    normalized_contact_details["city"] = stored_contact_field("city").to_s.strip
    normalized_contact_details["country"] = stored_contact_field("country").to_s.strip
    normalized_contact_details["pin_code"] = stored_contact_field("pin_code").to_s.strip
    normalized_contact_details["website"] = stored_contact_field("website").to_s.strip
    normalized_contact_details["linkedin"] = stored_contact_field("linkedin").to_s.strip
    normalized_contact_details["driving_licence"] = stored_contact_field("driving_licence").to_s.strip

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
    [stored_contact_field("first_name"), stored_contact_field("surname")].reject(&:blank?).join(" ")
  end

  def derived_location
    location_line = [stored_contact_field("city"), stored_contact_field("country")].reject(&:blank?).join(", ")
    [location_line, stored_contact_field("pin_code")].reject(&:blank?).join(" ")
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
end
