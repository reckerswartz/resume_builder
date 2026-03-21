require 'rails_helper'

RSpec.describe ApplicationPolicy do
  let(:admin) { create(:user, :admin) }
  let(:regular_user) { create(:user) }
  let(:record) { double('record') }

  describe 'default deny-all behavior' do
    subject(:policy) { described_class.new(regular_user, record) }

    it { is_expected.not_to be_index }
    it { is_expected.not_to be_show }
    it { is_expected.not_to be_create }
    it { is_expected.not_to be_update }
    it { is_expected.not_to be_destroy }
  end

  describe 'action aliases' do
    subject(:policy) { described_class.new(regular_user, record) }

    it 'delegates new? to create?' do
      expect(policy.new?).to eq(policy.create?)
    end

    it 'delegates edit? to update?' do
      expect(policy.edit?).to eq(policy.update?)
    end
  end

  describe ApplicationPolicy::Scope do
    it 'raises NoMethodError if resolve is not overridden' do
      expect { described_class.new(regular_user, Resume).resolve }.to raise_error(NoMethodError, /You must define #resolve/)
    end
  end
end
