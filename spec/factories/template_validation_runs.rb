FactoryBot.define do
  factory :template_validation_run do
    association :template
    template_implementation { nil }
    reference_artifact { nil }
    sequence(:identifier) { |n| "validation-run-#{n}" }
    validation_type { "manual_review" }
    status { "passed" }
    validator_name { "RSpec" }
    notes { "" }
    metrics { {} }
    metadata { {} }
    validated_at { Time.current }
  end
end
