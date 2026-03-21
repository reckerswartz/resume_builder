FactoryBot.define do
  factory :photo_asset_minimal, class: 'PhotoAsset' do
    association :photo_profile
    asset_kind { 'source' }
    status { 'ready' }
    metadata { {} }

    after(:build) do |asset|
      asset.file.attach(io: StringIO.new('fake png'), filename: 'test.png', content_type: 'image/png') unless asset.file.attached?
    end
  end
end
