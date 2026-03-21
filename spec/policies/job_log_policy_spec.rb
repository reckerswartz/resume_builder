require 'rails_helper'

RSpec.describe JobLogPolicy do
  subject(:policy) { described_class.new(user, job_log) }

  let(:admin) { create(:user, :admin) }
  let(:regular_user) { create(:user) }
  let(:job_log) { create(:job_log) }

  describe 'permissions for an admin' do
    let(:user) { admin }

    it { is_expected.to be_index }
    it { is_expected.to be_show }
    it { is_expected.to be_retry }
    it { is_expected.to be_discard }
    it { is_expected.to be_requeue }
  end

  describe 'permissions for a regular user' do
    let(:user) { regular_user }

    it { is_expected.not_to be_index }
    it { is_expected.not_to be_show }
    it { is_expected.not_to be_retry }
    it { is_expected.not_to be_discard }
    it { is_expected.not_to be_requeue }
  end

  describe 'permissions for a guest (nil user)' do
    let(:user) { nil }

    it { is_expected.not_to be_index }
    it { is_expected.not_to be_show }
    it { is_expected.not_to be_retry }
    it { is_expected.not_to be_discard }
    it { is_expected.not_to be_requeue }
  end

  describe JobLogPolicy::Scope do
    it 'returns all job logs for an admin' do
      create(:job_log)

      expect(described_class.new(admin, JobLog).resolve.count).to eq(JobLog.count)
    end

    it 'returns no job logs for a regular user' do
      create(:job_log)

      expect(described_class.new(regular_user, JobLog).resolve.count).to eq(0)
    end

    it 'returns no job logs for a nil user' do
      create(:job_log)

      expect(described_class.new(nil, JobLog).resolve.count).to eq(0)
    end
  end
end
