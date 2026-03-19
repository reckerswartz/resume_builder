FactoryBot.define do
  factory :section do
    association :resume
    title { "Experience" }
    section_type { "experience" }
    sequence(:position) { |n| n - 1 }
    settings { {} }
  end
end
