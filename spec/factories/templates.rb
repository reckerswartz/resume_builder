FactoryBot.define do
  factory :template do
    sequence(:name) { |n| "Template #{n}" }
    sequence(:slug) { |n| "template-#{n}" }
    description { "Clean professional resume layout" }
    active { true }
    layout_config { ResumeTemplates::Catalog.default_layout_config }
  end
end
