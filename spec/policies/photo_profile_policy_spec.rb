require 'rails_helper'

RSpec.describe PhotoProfilePolicy do
  subject(:policy) { described_class.new(user, photo_profile) }

  let(:owner) { create(:user) }
  let(:other_user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:photo_profile) { PhotoProfile.create!(user: owner, name: 'Profile', status: :active) }

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
    it { is_expected.to be_create }
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

  describe PhotoProfilePolicy::Scope do
    it 'returns only the user own profiles for a regular user' do
      photo_profile
      PhotoProfile.create!(user: other_user, name: 'Other', status: :active)

      resolved = described_class.new(owner, PhotoProfile).resolve
      expect(resolved).to include(photo_profile)
      expect(resolved.count).to eq(1)
    end

    it 'returns all profiles for an admin' do
      photo_profile
      PhotoProfile.create!(user: other_user, name: 'Other', status: :active)

      expect(described_class.new(admin, PhotoProfile).resolve.count).to eq(PhotoProfile.count)
    end

    it 'returns no profiles for a nil user' do
      photo_profile
      expect(described_class.new(nil, PhotoProfile).resolve.count).to eq(0)
    end
  end
end
