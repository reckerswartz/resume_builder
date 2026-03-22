require 'rails_helper'

RSpec.describe Admin::JobLogsHelper, type: :helper do
  describe '#job_duration_label' do
    it 'formats a duration in seconds' do
      expect(helper.job_duration_label(1.25)).to eq('1.25 seconds')
    end

    it 'returns N/A when no duration is present' do
      expect(helper.job_duration_label(nil)).to eq('N/A')
    end
  end

  describe '#job_log_related_error_state' do
    it 'builds a related error state with the preloaded matching error log when available' do
      job_log = create(:job_log, :failed, error_details: { 'reference_id' => 'ERR-JOB-0001' })
      error_log = create(:error_log, :job, reference_id: 'ERR-JOB-0001')

      helper.instance_variable_set(:@job_log_related_error_logs, { 'ERR-JOB-0001' => error_log })

      state = helper.job_log_related_error_state(job_log)

      expect(state).to be_a(Admin::JobLogs::RelatedErrorState)
      expect(state.reference).to eq('ERR-JOB-0001')
      expect(state.error_log).to eq(error_log)
    end
  end

  describe '#formatted_debug_payload' do
    it 'serializes hashes with string keys' do
      payload = helper.formatted_debug_payload(resume_id: 12, nested: { status: 'ok' })

      expect(payload).to include('"resume_id": 12')
      expect(payload).to include('"status": "ok"')
    end
  end

  describe '#job_log_runtime_state' do
    it 'returns a RuntimeState presenter' do
      job_log = create(:job_log)
      queue_snapshot = double("QueueSnapshot", unavailable?: true)

      state = helper.job_log_runtime_state(job_log, queue_snapshot)

      expect(state).to be_a(Admin::JobLogs::RuntimeState)
    end
  end

  describe '#job_log_control_state' do
    it 'returns a ControlState presenter' do
      job_log = create(:job_log, :failed)
      queue_snapshot = double("QueueSnapshot", retryable?: false)

      state = helper.job_log_control_state(job_log, queue_snapshot)

      expect(state).to be_a(Admin::JobLogs::ControlState)
    end
  end
end
