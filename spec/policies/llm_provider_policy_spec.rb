require 'rails_helper'

RSpec.describe LlmProviderPolicy do
  subject(:policy) { described_class.new(user, provider) }

  let(:admin) { create(:user, :admin) }
  let(:regular_user) { create(:user) }
  let(:provider) { create(:llm_provider) }

  describe 'permissions for an admin' do
    let(:user) { admin }

    it { is_expected.to be_index }
    it { is_expected.to be_show }
    it { is_expected.to be_create }
    it { is_expected.to be_update }
    it { is_expected.to be_destroy }
    it { is_expected.to be_sync_models }
  end

  describe 'permissions for a regular user' do
    let(:user) { regular_user }

    it { is_expected.not_to be_index }
    it { is_expected.not_to be_show }
    it { is_expected.not_to be_create }
    it { is_expected.not_to be_update }
    it { is_expected.not_to be_destroy }
    it { is_expected.not_to be_sync_models }
  end

  describe 'permissions for a guest (nil user)' do
    let(:user) { nil }

    it { is_expected.not_to be_index }
    it { is_expected.not_to be_show }
    it { is_expected.not_to be_create }
    it { is_expected.not_to be_update }
    it { is_expected.not_to be_destroy }
    it { is_expected.not_to be_sync_models }
  end

  describe LlmProviderPolicy::Scope do
    it 'returns all providers for an admin' do
      create(:llm_provider)

      expect(described_class.new(admin, LlmProvider).resolve.count).to eq(LlmProvider.count)
    end

    it 'returns no providers for a regular user' do
      create(:llm_provider)

      expect(described_class.new(regular_user, LlmProvider).resolve.count).to eq(0)
    end

    it 'returns no providers for a nil user' do
      create(:llm_provider)

      expect(described_class.new(nil, LlmProvider).resolve.count).to eq(0)
    end
  end
end
