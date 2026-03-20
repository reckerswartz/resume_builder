FactoryBot.define do
  factory :llm_model do
    association :llm_provider
    sequence(:name) { |n| "Model #{n}" }
    sequence(:identifier) { |n| "model-#{n}" }
    active { true }
    supports_text { true }
    supports_vision { false }
    settings { { "temperature" => 0.2, "max_output_tokens" => 300 } }
    metadata { {} }

    trait :inactive do
      active { false }
    end

    trait :vision_capable do
      supports_vision { true }
    end
  end
end
