require 'rails_helper'

RSpec.describe Admin::JobLogs::RelatedErrorState do
  def build_state(job_log:, error_log: nil, error_log_loaded: false)
    described_class.new(job_log: job_log, error_log: error_log, error_log_loaded: error_log_loaded)
  end

  describe '#reference' do
    it 'returns the recorded reference id when present' do
      job_log = create(:job_log, :failed, error_details: { 'reference_id' => 'ERR-JOB-0001' })

      expect(build_state(job_log: job_log).reference).to eq('ERR-JOB-0001')
    end
  end

  describe '#error_log' do
    it 'uses the preloaded error log when provided' do
      job_log = create(:job_log, :failed, error_details: { 'reference_id' => 'ERR-JOB-0001' })
      error_log = create(:error_log, :job, reference_id: 'ERR-JOB-0001')

      state = build_state(job_log: job_log, error_log: error_log, error_log_loaded: true)

      expect(state.error_log).to eq(error_log)
    end

    it 'loads the matching error log when not preloaded' do
      job_log = create(:job_log, :failed, error_details: { 'reference_id' => 'ERR-JOB-0001' })
      error_log = create(:error_log, :job, reference_id: 'ERR-JOB-0001')

      expect(build_state(job_log: job_log).error_log).to eq(error_log)
    end
  end

  describe '#tracked?' do
    it 'is true when a failed job has no recorded reference yet' do
      job_log = create(:job_log, :failed, error_details: {})

      expect(build_state(job_log: job_log).tracked?).to be(true)
    end

    it 'is false when the job is not failed and no reference was recorded' do
      job_log = create(:job_log, :succeeded, error_details: {})

      expect(build_state(job_log: job_log).tracked?).to be(false)
    end
  end

  describe '#description' do
    it 'returns the available message when a matching error log exists' do
      job_log = create(:job_log, :failed, error_details: { 'reference_id' => 'ERR-JOB-0001' })
      error_log = create(:error_log, :job, reference_id: 'ERR-JOB-0001')

      description = build_state(job_log: job_log, error_log: error_log, error_log_loaded: true).description

      expect(description).to eq(I18n.t('admin.job_logs.helper.related_error_descriptions.available'))
    end

    it 'returns the reference-only message when no matching error log exists' do
      job_log = create(:job_log, :failed, error_details: { 'reference_id' => 'ERR-JOB-0001' })

      expect(build_state(job_log: job_log).description).to eq(I18n.t('admin.job_logs.helper.related_error_descriptions.reference_only'))
    end

    it 'returns the failed-without-reference message for failed jobs without a reference' do
      job_log = create(:job_log, :failed, error_details: {})

      expect(build_state(job_log: job_log).description).to eq(I18n.t('admin.job_logs.helper.related_error_descriptions.failed_without_reference'))
    end

    it 'returns the neutral none message for non-failed jobs without a reference' do
      job_log = create(:job_log, :succeeded, error_details: {})

      expect(build_state(job_log: job_log).description).to eq(I18n.t('admin.job_logs.helper.related_error_descriptions.none'))
    end
  end
end
