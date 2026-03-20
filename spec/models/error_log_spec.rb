require 'rails_helper'

RSpec.describe ErrorLog, type: :model do
  describe '#duration_seconds' do
    it 'converts milliseconds to seconds' do
      error_log = build(:error_log, duration_ms: 1250)

      expect(error_log.duration_seconds).to eq(1.25)
    end
  end

  describe 'callbacks' do
    it 'assigns a reference id and stringifies payload keys' do
      error_log = described_class.create!(
        source: 'request',
        error_class: 'StandardError',
        message: 'Boom',
        context: { request_id: 'req-1', nested: { job_id: 12 } },
        backtrace_lines: [:line],
        occurred_at: Time.current
      )

      expect(error_log.reference_id).to start_with('ERR-')
      expect(error_log.context).to eq('request_id' => 'req-1', 'nested' => { 'job_id' => 12 })
      expect(error_log.backtrace_lines).to eq(['line'])
    end

    it 'wraps non-hash context payloads instead of raising' do
      error_log = described_class.create!(
        source: 'request',
        error_class: 'StandardError',
        message: 'Boom',
        context: [1, 2, 3],
        backtrace_lines: nil,
        occurred_at: Time.current
      )

      expect(error_log.context).to eq('value' => [1, 2, 3])
      expect(error_log.backtrace_lines).to eq([])
    end
  end
end
