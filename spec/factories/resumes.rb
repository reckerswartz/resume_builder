FactoryBot.define do
  factory :resume do
    association :user
    association :template
    sequence(:title) { |n| "Resume #{n}" }
    headline { Faker::Job.title }
    sequence(:slug) { |n| "resume-#{n}" }
    contact_details do
      {
        "full_name" => Faker::Name.name,
        "email" => Faker::Internet.safe_email,
        "phone" => Faker::PhoneNumber.cell_phone,
        "location" => Faker::Address.city,
        "website" => Faker::Internet.url,
        "linkedin" => Faker::Internet.url(host: "linkedin.com")
      }
    end
    settings { { "accent_color" => "#0F172A", "show_contact_icons" => true, "page_size" => "A4" } }
    summary { Faker::Lorem.sentence(word_count: 10) }
  end
end
