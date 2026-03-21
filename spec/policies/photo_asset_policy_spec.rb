require 'rails_helper'

RSpec.describe PhotoAssetPolicy do
  subject(:policy) { described_class.new(user, photo_asset) }

  let(:owner) { create(:user) }
  let(:other_user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:photo_profile) { PhotoProfile.create!(user: owner, name: 'Profile', status: :active) }
  let(:photo_asset) do
    PhotoAsset.new(photo_profile: photo_profile, asset_kind: :source, status: :ready).tap do |asset|
      asset.file.attach(io: StringIO.new('png'), filename: 'test.png', content_type: 'image/png')
      asset.save!
    end
  end

  describe 'permissions for the profile owner' do
    let(:user) { owner }

    it { is_expected.to be_show }
    it { is_expected.to be_create }
    it { is_expected.to be_update }
    it { is_expected.to be_destroy }
  end

  describe 'permissions for a different user' do
    let(:user) { other_user }

    it { is_expected.not_to be_show }
    it { is_expected.not_to be_create }
    it { is_expected.not_to be_update }
    it { is_expected.not_to be_destroy }
  end

  describe 'permissions for an admin' do
    let(:user) { admin }

    it { is_expected.to be_show }
    it { is_expected.to be_create }
    it { is_expected.to be_update }
    it { is_expected.to be_destroy }
  end

  describe 'permissions for a guest' do
    let(:user) { nil }

    it { is_expected.not_to be_show }
    it { is_expected.not_to be_create }
    it { is_expected.not_to be_update }
    it { is_expected.not_to be_destroy }
  end

  describe PhotoAssetPolicy::Scope do
    it 'returns only the owner assets for a regular user' do
      photo_asset # ensure created
      other_profile = PhotoProfile.create!(user: other_user, name: 'Other', status: :active)
      PhotoAsset.new(photo_profile: other_profile, asset_kind: :source, status: :ready).tap do |a|
        a.file.attach(io: StringIO.new('png'), filename: 'other.png', content_type: 'image/png')
        a.save!
      end

      resolved = described_class.new(owner, PhotoAsset).resolve
      expect(resolved).to include(photo_asset)
      expect(resolved.count).to eq(owner_asset_count(owner))
    end

    it 'returns all assets for an admin' do
      photo_asset
      expect(described_class.new(admin, PhotoAsset).resolve.count).to eq(PhotoAsset.count)
    end

    it 'returns no assets for a nil user' do
      photo_asset
      expect(described_class.new(nil, PhotoAsset).resolve.count).to eq(0)
    end
  end

  private

  def owner_asset_count(user)
    PhotoAsset.joins(:photo_profile).where(photo_profiles: { user_id: user.id }).count
  end
end
