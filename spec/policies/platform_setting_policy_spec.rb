require 'rails_helper'

RSpec.describe PlatformSettingPolicy do
  subject(:policy) { described_class.new(user, PlatformSetting.current) }

  let(:admin) { create(:user, :admin) }
  let(:regular_user) { create(:user) }

  describe 'permissions for an admin' do
    let(:user) { admin }

    it { is_expected.to be_show }
    it { is_expected.to be_update }
  end

  describe 'permissions for a regular user' do
    let(:user) { regular_user }

    it { is_expected.not_to be_show }
    it { is_expected.not_to be_update }
  end

  describe 'permissions for a guest' do
    let(:user) { nil }

    it { is_expected.not_to be_show }
    it { is_expected.not_to be_update }
  end
end
