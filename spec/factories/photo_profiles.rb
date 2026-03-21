FactoryBot.define do
  factory :photo_profile do
    association :user
    name { 'Primary Photo Library' }
    status { 'active' }
  end
end
