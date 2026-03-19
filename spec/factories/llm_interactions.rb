FactoryBot.define do
  factory :llm_interaction do
    user { nil }
    resume { nil }
    feature_name { "MyString" }
    status { "MyString" }
    prompt { "MyText" }
    response { "MyText" }
    token_usage { "" }
    latency_ms { 1 }
    metadata { "" }
    error_message { "MyText" }
  end
end
