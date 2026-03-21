FactoryBot.define do
  factory :template_artifact do
    association :template
    artifact_type { "design_note" }
    sequence(:name) { |n| "Artifact #{n}" }
    description { "Template artifact" }
    content { "" }
    metadata { {} }
    version_label { "v1.0" }
    status { "active" }
  end
end
