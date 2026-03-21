require 'rails_helper'

RSpec.describe AdminPolicy do
  subject(:policy) { described_class.new(user, :admin) }

  describe 'permissions for an admin' do
    let(:user) { create(:user, :admin) }

    it { is_expected.to be_access }
  end

  describe 'permissions for a regular user' do
    let(:user) { create(:user) }

    it { is_expected.not_to be_access }
  end

  describe 'permissions for a guest (nil user)' do
    let(:user) { nil }

    it { is_expected.not_to be_access }
  end
end
