require 'rails_helper'

RSpec.describe ResumePolicy do
  subject(:policy) { described_class.new(user, resume) }

  let(:owner) { create(:user) }
  let(:other_user) { create(:user) }
  let(:admin) { create(:user, :admin) }
  let(:resume) { create(:resume, user: owner) }

  describe 'permissions for the resume owner' do
    let(:user) { owner }

    it { is_expected.to be_index }
    it { is_expected.to be_show }
    it { is_expected.to be_create }
    it { is_expected.to be_update }
    it { is_expected.to be_destroy }
    it { is_expected.to be_export }
    it { is_expected.to be_download }
  end

  describe 'permissions for a different authenticated user' do
    let(:user) { other_user }

    it { is_expected.to be_index }
    it { is_expected.not_to be_show }
    it { is_expected.to be_create }
    it { is_expected.not_to be_update }
    it { is_expected.not_to be_destroy }
    it { is_expected.not_to be_export }
    it { is_expected.not_to be_download }
  end

  describe 'permissions for an admin' do
    let(:user) { admin }

    it { is_expected.to be_index }
    it { is_expected.to be_show }
    it { is_expected.to be_create }
    it { is_expected.to be_update }
    it { is_expected.to be_destroy }
    it { is_expected.to be_export }
    it { is_expected.to be_download }
  end

  describe 'permissions for a guest (nil user)' do
    let(:user) { nil }

    it { is_expected.not_to be_index }
    it { is_expected.not_to be_show }
    it { is_expected.not_to be_create }
    it { is_expected.not_to be_update }
    it { is_expected.not_to be_destroy }
    it { is_expected.not_to be_export }
    it { is_expected.not_to be_download }
  end

  describe ResumePolicy::Scope do
    it 'returns only the user own resumes for a regular user' do
      own_resume = create(:resume, user: owner)
      create(:resume, user: other_user)

      resolved = described_class.new(owner, Resume).resolve

      expect(resolved).to include(own_resume)
      expect(resolved.count).to eq(owner.resumes.count)
    end

    it 'returns all resumes for an admin' do
      create(:resume, user: owner)
      create(:resume, user: other_user)

      resolved = described_class.new(admin, Resume).resolve

      expect(resolved.count).to eq(Resume.count)
    end

    it 'returns no resumes for a nil user' do
      create(:resume, user: owner)

      resolved = described_class.new(nil, Resume).resolve

      expect(resolved.count).to eq(0)
    end
  end
end
