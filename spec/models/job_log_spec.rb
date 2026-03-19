require 'rails_helper'

RSpec.describe JobLog, type: :model do
  describe '#duration_seconds' do
    it 'converts milliseconds to seconds' do
      job_log = build(:job_log, duration_ms: 1250)

      expect(job_log.duration_seconds).to eq(1.25)
    end
  end

  describe 'callbacks' do
    it 'stringifies payload keys' do
      job_log = described_class.create!(
        active_job_id: 'job-1',
        job_type: 'ResumeExportJob',
        queue_name: 'default',
        status: 'queued',
        input: { resume_id: 12 },
        output: { filename: 'resume.pdf' },
        error_details: { message: 'none' }
      )

      expect(job_log.input).to eq('resume_id' => 12)
      expect(job_log.output).to eq('filename' => 'resume.pdf')
      expect(job_log.error_details).to eq('message' => 'none')
    end

    it 'wraps non-hash payloads instead of raising' do
      job_log = described_class.create!(
        active_job_id: 'job-2',
        job_type: 'ResumeExportJob',
        queue_name: 'default',
        status: 'queued',
        input: [1, 2, 3],
        output: nil,
        error_details: nil
      )

      expect(job_log.input).to eq('value' => [1, 2, 3])
      expect(job_log.output).to eq({})
      expect(job_log.error_details).to eq({})
    end
  end
end
