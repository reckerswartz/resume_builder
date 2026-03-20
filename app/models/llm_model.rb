class LlmModel < ApplicationRecord
  ADMIN_SORTS = %w[name provider active updated_at].freeze

  belongs_to :llm_provider

  has_many :llm_interactions, dependent: :nullify
  has_many :llm_model_assignments, dependent: :destroy

  scope :active, -> { where(active: true) }
  scope :ordered, -> { includes(:llm_provider).order(:name, :identifier) }
  scope :text_capable, -> { where(supports_text: true) }
  scope :vision_capable, -> { where(supports_vision: true) }
  scope :matching_query, ->(query) do
    next all if query.blank?

    term = "%#{ActiveRecord::Base.sanitize_sql_like(query.to_s.strip)}%"
    left_outer_joins(:llm_provider)
      .where("llm_models.name ILIKE :term OR llm_models.identifier ILIKE :term OR llm_providers.name ILIKE :term", term: term)
      .distinct
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
  scope :with_capability_filter, ->(value) do
    case value
    when "text"
      where(supports_text: true)
    when "vision"
      where(supports_vision: true)
    else
      all
    end
  end

  before_validation :normalize_attributes

  validates :name, presence: true
  validates :identifier, presence: true, uniqueness: { scope: :llm_provider_id }

  def self.admin_sort_column(value)
    ADMIN_SORTS.include?(value) ? value : "name"
  end

  def self.sorted_for_admin(sort, direction)
    case admin_sort_column(sort)
    when "provider"
      left_outer_joins(:llm_provider).includes(:llm_provider).distinct.order(Arel.sql("llm_providers.name #{direction.upcase}"), name: :asc, identifier: :asc)
    else
      order(admin_order_hash(admin_sort_column(sort), direction))
    end
  end

  def temperature
    return if settings["temperature"].blank?

    settings["temperature"].to_f
  end

  def max_output_tokens
    return if settings["max_output_tokens"].blank?

    settings["max_output_tokens"].to_i
  end

  def catalog_source
    metadata["catalog_source"].presence
  end

  def provider_synced?
    catalog_source == Llm::ProviderModelSyncService::CATALOG_SOURCE
  end

  def model_type
    metadata["model_type"].presence || inferred_model_type
  end

  def owned_by
    metadata["owned_by"].presence
  end

  def family
    metadata["family"].presence || Array(metadata["families"]).first.presence
  end

  def parameter_size
    metadata["parameter_size"].presence
  end

  def quantization_level
    metadata["quantization_level"].presence
  end

  def input_modalities
    Array(metadata["input_modalities"]).filter_map(&:presence)
  end

  def output_modalities
    Array(metadata["output_modalities"]).filter_map(&:presence)
  end

  def modality_summary
    return if input_modalities.blank? && output_modalities.blank?

    parts = []
    parts << "In: #{input_modalities.map(&:humanize).to_sentence}" if input_modalities.any?
    parts << "Out: #{output_modalities.map(&:humanize).to_sentence}" if output_modalities.any?
    parts.join(" · ")
  end

  def metadata_summary_parts
    [ model_type_label, family, parameter_size, owned_by ].compact_blank
  end

  def model_type_label
    model_type.to_s.humanize.presence
  end

  def supports_role?(role)
    case role.to_s
    when "text_generation", "text_verification"
      supports_text?
    when "vision_generation", "vision_verification"
      supports_vision?
    else
      false
    end
  end

  private
    def self.admin_order_hash(sort, direction)
      case sort
      when "active"
        { active: direction.to_sym, name: :asc, identifier: :asc }
      when "updated_at"
        { updated_at: direction.to_sym, name: :asc, identifier: :asc }
      else
        { name: direction.to_sym, identifier: :asc }
      end
    end

    def normalize_attributes
      self.name = name.to_s.strip
      self.identifier = identifier.to_s.strip
      self.settings = (settings || {}).deep_stringify_keys
      self.metadata = (metadata || {}).deep_stringify_keys
    end

    def inferred_model_type
      return "multimodal" if supports_text? && supports_vision?
      return "vision" if supports_vision?
      return "text" if supports_text?

      "unknown"
    end
end
