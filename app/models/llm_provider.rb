class LlmProvider < ApplicationRecord
  include LlmProvider::CredentialManagement

  OLLAMA_BASE_URL = "http://127.0.0.1:11434".freeze
  NVIDIA_BUILD_BASE_URL = "https://integrate.api.nvidia.com".freeze
  ADMIN_SORTS = {
    "name" => ->(direction) { { name: direction, slug: :asc } },
    "adapter" => ->(direction) { { adapter: direction, name: :asc } },
    "active" => ->(direction) { { active: direction, name: :asc } },
    "updated_at" => ->(direction) { { updated_at: direction, name: :asc } }
  }.freeze

  has_many :llm_interactions, dependent: :nullify
  has_many :llm_models, dependent: :destroy

  enum :adapter, { ollama: "ollama", nvidia_build: "nvidia_build" }, validate: true

  scope :active, -> { where(active: true) }
  scope :matching_query, ->(query) do
    next all if query.blank?

    term = "%#{ActiveRecord::Base.sanitize_sql_like(query.to_s.strip)}%"
    where("llm_providers.name ILIKE :term OR llm_providers.slug ILIKE :term OR llm_providers.base_url ILIKE :term", term: term)
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
  scope :with_adapter_filter, ->(value) do
    adapters.key?(value) ? where(adapter: value) : all
  end

  before_validation :normalize_name
  before_validation :normalize_slug
  before_validation :normalize_api_key_reference
  before_validation :normalize_settings
  before_validation :assign_default_base_url

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true
  validates :adapter, presence: true
  validates :base_url, presence: true
  validates :api_key_env_var, presence: true, if: :nvidia_build?

  def self.admin_sort_column(value)
    ADMIN_SORTS.key?(value) ? value : "name"
  end

  def self.sorted_for_admin(sort, direction)
    order(ADMIN_SORTS.fetch(admin_sort_column(sort)).call(direction.to_sym))
  end

  def request_timeout_seconds
    timeout = settings.fetch("request_timeout_seconds", 30).to_i
    timeout.positive? ? timeout : 30
  end

  def syncable?
    return false if base_url.blank?
    return true unless nvidia_build?

    api_key.present?
  end

  def syncability_error
    return if syncable?
    return "#{name} needs an API key reference or token." if nvidia_build? && api_key_reference.blank?
    return "#{name} could not resolve #{api_key_reference}." if nvidia_build? && api_key_reference_type == "env_var"

    "#{name} is not ready for requests."
  end

  def configured_for_requests?
    return false unless active?

    syncable?
  end

  def last_synced_at
    parse_settings_time("last_synced_at")
  end

  def last_sync_attempt_at
    parse_settings_time("last_sync_attempt_at")
  end

  def last_synced_model_count
    count = settings["last_synced_model_count"]
    count.present? ? count.to_i : nil
  end

  def last_sync_error
    settings["last_sync_error"].presence
  end

  def sync_status
    return :error if last_sync_error.present?
    return :synced if last_synced_at.present?

    :never_synced
  end

  private
    def normalize_name
      self.name = name.to_s.strip
    end

    def normalize_slug
      self.slug = (slug.presence || name).to_s.parameterize
    end

    def normalize_api_key_reference
      self.api_key_env_var = api_key_reference
    end

    def normalize_settings
      normalized_settings = (settings || {}).deep_stringify_keys
      timeout = normalized_settings["request_timeout_seconds"].presence || 30
      normalized_settings["request_timeout_seconds"] = timeout.to_i
      self.settings = normalized_settings
    end

    def assign_default_base_url
      self.base_url = default_base_url if base_url.blank?
    end

    def default_base_url
      case adapter
      when "ollama"
        OLLAMA_BASE_URL
      when "nvidia_build"
        NVIDIA_BUILD_BASE_URL
      end
    end

    def parse_settings_time(key)
      value = settings[key].presence
      return if value.blank?

      Time.zone.parse(value)
    rescue ArgumentError, TypeError
      nil
    end
end
