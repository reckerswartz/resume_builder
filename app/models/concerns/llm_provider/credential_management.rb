module LlmProvider::CredentialManagement
  extend ActiveSupport::Concern

  API_KEY_ENV_VAR_PATTERN = /\A[A-Z_][A-Z0-9_]*\z/.freeze

  def api_key_reference
    api_key_env_var.to_s.strip.presence
  end

  def api_key
    return if api_key_reference.blank?
    return ENV[api_key_reference].presence if env_var_reference?(api_key_reference)

    api_key_reference
  end

  def api_key_reference_type
    return if api_key_reference.blank?

    env_var_reference?(api_key_reference) ? "env_var" : "direct_token"
  end

  def api_key_reference_field_value
    api_key_reference if api_key_reference_type == "env_var"
  end

  def masked_api_key_reference
    return if api_key_reference.blank?
    return api_key_reference if api_key_reference_type == "env_var"
    return "••••••••" if api_key_reference.length <= 10

    "#{api_key_reference.first(6)}••••#{api_key_reference.last(4)}"
  end

  private
    def env_var_reference?(value)
      value.to_s.match?(API_KEY_ENV_VAR_PATTERN)
    end
end
