require 'rails_helper'

RSpec.describe ErrorLogPolicy do
  subject(:policy) { described_class.new(user, error_log) }

  let(:admin) { create(:user, :admin) }
  let(:regular_user) { create(:user) }
  let(:error_log) { create(:error_log) }

  describe 'permissions for an admin' do
    let(:user) { admin }

    it { is_expected.to be_index }
    it { is_expected.to be_show }
  end

  describe 'permissions for a regular user' do
    let(:user) { regular_user }

    it { is_expected.not_to be_index }
    it { is_expected.not_to be_show }
  end

  describe 'permissions for a guest' do
    let(:user) { nil }

    it { is_expected.not_to be_index }
    it { is_expected.not_to be_show }
  end

  describe ErrorLogPolicy::Scope do
    it 'returns all error logs for an admin' do
      create(:error_log)
      expect(described_class.new(admin, ErrorLog).resolve.count).to eq(ErrorLog.count)
    end

    it 'returns none for a regular user' do
      create(:error_log)
      expect(described_class.new(regular_user, ErrorLog).resolve.count).to eq(0)
    end

    it 'returns none for a nil user' do
      create(:error_log)
      expect(described_class.new(nil, ErrorLog).resolve.count).to eq(0)
    end
  end
end
