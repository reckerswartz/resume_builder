FactoryBot.define do
  factory :entry do
    association :section
    sequence(:position) { |n| n - 1 }
    content { { "title" => "Senior Engineer", "organization" => "Acme", "highlights" => [ "Improved platform performance" ] } }
  end
end
