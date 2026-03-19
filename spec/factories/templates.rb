FactoryBot.define do
  factory :template do
    sequence(:name) { |n| "Template #{n}" }
    sequence(:slug) { |n| "template-#{n}" }
    description { "Clean professional resume layout" }
    active { true }
    layout_config { { "variant" => "modern", "accent_color" => "#0F172A", "font_scale" => "base" } }
  end
end
