FactoryBot.define do
  factory :llm_model_assignment do
    association :llm_model
    role { "text_generation" }
    position { 0 }
  end
end
