FactoryBot.define do
  factory :llm_provider do
    sequence(:name) { |n| "Provider #{n}" }
    sequence(:slug) { |n| "provider-#{n}" }
    adapter { "ollama" }
    base_url { "http://127.0.0.1:11434" }
    api_key_env_var { nil }
    active { true }
    settings { { "request_timeout_seconds" => 30 } }

    trait :inactive do
      active { false }
    end

    trait :nvidia_build do
      adapter { "nvidia_build" }
      base_url { "https://integrate.api.nvidia.com" }
      api_key_env_var { "NVIDIA_API_KEY" }
    end
  end
end
