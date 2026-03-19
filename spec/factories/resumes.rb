FactoryBot.define do
  factory :resume do
    association :user
    association :template
    sequence(:title) { |n| "Resume #{n}" }
    headline { "Senior Rails Engineer" }
    sequence(:slug) { |n| "resume-#{n}" }
    contact_details { { "full_name" => "Casey Example", "email" => "candidate@example.com", "phone" => "", "location" => "", "website" => "", "linkedin" => "" } }
    settings { { "accent_color" => "#0F172A", "show_contact_icons" => true, "page_size" => "A4" } }
    summary { "Builds reliable, user-friendly products with Rails and Hotwire." }
  end
end
