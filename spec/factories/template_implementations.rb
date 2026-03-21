FactoryBot.define do
  factory :template_implementation do
    association :template
    source_artifact { nil }
    sequence(:name) { |n| "Implementation #{n}" }
    sequence(:identifier) { |n| "implementation-#{n}" }
    status { "validated" }
    renderer_family { template.layout_family }
    render_profile { template.normalized_layout_config }
    notes { "" }
    metadata { {} }
    validated_at { Time.current }
    seeded_at { nil }
  end
end
