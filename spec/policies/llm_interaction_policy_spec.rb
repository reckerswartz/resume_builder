require 'rails_helper'

RSpec.describe LlmInteractionPolicy do
  subject(:policy) { described_class.new(user, :llm_interaction) }

  let(:admin) { create(:user, :admin) }
  let(:regular_user) { create(:user) }

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

  describe LlmInteractionPolicy::Scope do
    it 'returns all interactions for an admin' do
      expect(described_class.new(admin, LlmInteraction).resolve).to eq(LlmInteraction.all)
    end

    it 'returns none for a regular user' do
      expect(described_class.new(regular_user, LlmInteraction).resolve.count).to eq(0)
    end
  end
end
