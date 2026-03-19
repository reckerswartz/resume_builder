FactoryBot.define do
  factory :llm_interaction do
    association :user
    association :resume, user: user
    feature_name { "resume_suggestions" }
    status { "queued" }
    prompt { "Improve these bullets" }
    response { "Delivered measurable improvements" }
    token_usage { { "input_tokens" => 20, "output_tokens" => 10 } }
    latency_ms { 120 }
    metadata { { "entry_id" => 1 } }
    error_message { nil }
  end
end
