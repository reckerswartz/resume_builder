FactoryBot.define do
  factory :llm_interaction do
    association :user
    association :resume, user: user
    llm_model { nil }
    llm_provider { llm_model&.llm_provider }
    feature_name { "resume_suggestions" }
    role { nil }
    status { "queued" }
    prompt { "Improve these bullets" }
    response { "Delivered measurable improvements" }
    token_usage { { "input_tokens" => 20, "output_tokens" => 10 } }
    latency_ms { 120 }
    metadata { { "entry_id" => 1 } }
    error_message { nil }
  end
end
