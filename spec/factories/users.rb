FactoryBot.define do
  factory :user do
    sequence(:email_address) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { password }
    role { :user }

    trait :admin do
      role { :admin }
    end
  end
end
