require 'rails_helper'

RSpec.describe PhotoProfile, type: :model do
  let(:user) { create(:user) }

  def create_profile(name: 'Test Profile', status: :active, **attrs)
    PhotoProfile.create!(user: user, name: name, status: status, **attrs)
  end

  def create_asset(profile:, asset_kind: :source, status: :ready, filename: 'test.png', source_asset: nil)
    PhotoAsset.new(photo_profile: profile, asset_kind: asset_kind, status: status, source_asset: source_asset).tap do |asset|
      asset.file.attach(io: StringIO.new('png'), filename: filename, content_type: 'image/png')
      asset.save!
    end
  end

  describe 'validations' do
    it 'requires a name' do
      profile = PhotoProfile.new(user: user, name: '')

      expect(profile).not_to be_valid
      expect(profile.errors[:name]).to include("can't be blank")
    end

    it 'rejects a selected_source_photo_asset from a different profile' do
      profile = create_profile
      other_profile = create_profile(name: 'Other')
      asset = create_asset(profile: other_profile)

      profile.selected_source_photo_asset = asset

      expect(profile).not_to be_valid
      expect(profile.errors[:selected_source_photo_asset]).to include('must belong to the same photo profile')
    end

    it 'accepts a selected_source_photo_asset from the same profile' do
      profile = create_profile
      asset = create_asset(profile: profile)

      profile.selected_source_photo_asset = asset

      expect(profile).to be_valid
    end
  end

  describe 'normalization' do
    it 'defaults status to draft when nil' do
      profile = PhotoProfile.new(user: user, name: 'Test', status: nil)
      profile.valid?

      expect(profile.status).to eq('draft')
    end

    it 'deep-stringifies preferences on save' do
      profile = create_profile
      profile.update!(preferences: { theme: 'dark' })

      expect(profile.preferences.keys).to all(be_a(String))
    end
  end

  describe '.default_for' do
    it 'returns the existing profile when one exists' do
      existing = create_profile
      expect(PhotoProfile.default_for(user)).to eq(existing)
    end

    it 'creates a new profile when none exists' do
      expect { PhotoProfile.default_for(user) }.to change(PhotoProfile, :count).by(1)

      profile = PhotoProfile.default_for(user)
      expect(profile.name).to include('Photo Library')
      expect(profile).to be_active
    end
  end

  describe '#preferred_headshot_asset' do
    it 'returns the highest-priority ready asset' do
      profile = create_profile
      source = create_asset(profile: profile, asset_kind: :source, status: :ready)
      enhanced = create_asset(profile: profile, asset_kind: :enhanced, status: :ready, source_asset: source, filename: 'enhanced.png')

      expect(profile.preferred_headshot_asset).to eq(enhanced)
    end

    it 'falls back to selected_source_photo_asset when no ready assets exist' do
      profile = create_profile
      source = create_asset(profile: profile, asset_kind: :source, status: :uploaded)
      profile.update!(selected_source_photo_asset: source)

      expect(profile.preferred_headshot_asset).to eq(source)
    end

    it 'returns nil when no assets exist' do
      profile = create_profile

      expect(profile.preferred_headshot_asset).to be_nil
    end
  end

  describe 'enums' do
    it 'supports draft, active, and archived statuses' do
      %w[draft active archived].each do |s|
        profile = create_profile(status: s, name: "#{s} profile")
        expect(profile.status).to eq(s)
      end
    end
  end
end
