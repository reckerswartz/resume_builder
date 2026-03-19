FactoryBot.define do
  factory :platform_setting do
    sequence(:name) { |n| "settings-#{n}" }
    feature_flags { { "llm_access" => false, "resume_suggestions" => false, "autofill_content" => false } }
    preferences { { "default_template_slug" => "modern", "support_email" => "support@example.com" } }
  end
end
