require 'rails_helper'

RSpec.describe LlmModelPolicy do
  subject(:policy) { described_class.new(user, model) }

  let(:admin) { create(:user, :admin) }
  let(:regular_user) { create(:user) }
  let(:provider) { create(:llm_provider) }
  let(:model) { create(:llm_model, llm_provider: provider) }

  describe 'permissions for an admin' do
    let(:user) { admin }

    it { is_expected.to be_index }
    it { is_expected.to be_show }
    it { is_expected.to be_create }
    it { is_expected.to be_update }
    it { is_expected.to be_destroy }
  end

  describe 'permissions for a regular user' do
    let(:user) { regular_user }

    it { is_expected.not_to be_index }
    it { is_expected.not_to be_show }
    it { is_expected.not_to be_create }
    it { is_expected.not_to be_update }
    it { is_expected.not_to be_destroy }
  end

  describe 'permissions for a guest (nil user)' do
    let(:user) { nil }

    it { is_expected.not_to be_index }
    it { is_expected.not_to be_show }
    it { is_expected.not_to be_create }
    it { is_expected.not_to be_update }
    it { is_expected.not_to be_destroy }
  end

  describe LlmModelPolicy::Scope do
    it 'returns all models for an admin' do
      create(:llm_model, llm_provider: provider)

      expect(described_class.new(admin, LlmModel).resolve.count).to eq(LlmModel.count)
    end

    it 'returns no models for a regular user' do
      create(:llm_model, llm_provider: provider)

      expect(described_class.new(regular_user, LlmModel).resolve.count).to eq(0)
    end

    it 'returns no models for a nil user' do
      create(:llm_model, llm_provider: provider)

      expect(described_class.new(nil, LlmModel).resolve.count).to eq(0)
    end
  end
end
