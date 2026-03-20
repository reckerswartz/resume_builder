require 'rails_helper'

RSpec.describe JobLog, type: :model do
  describe '#duration_seconds' do
    it 'converts milliseconds to seconds' do
      job_log = build(:job_log, duration_ms: 1250)

      expect(job_log.duration_seconds).to eq(1.25)
    end
  end

  describe '.for_resume_export' do
    it 'filters export logs by the resume id stored in the job arguments' do
      resume = create(:resume)
      matching_log = create(:job_log, input: { 'arguments' => [resume.id, resume.user.id] })
      create(:job_log, input: { 'arguments' => [create(:resume).id, resume.user.id] })

      expect(described_class.for_resume_export(resume.id)).to eq([matching_log])
    end
  end

  describe '#resume_id' do
    it 'extracts the resume id from the export job payload' do
      job_log = build(:job_log, input: { 'arguments' => [42, 9] })

      expect(job_log.resume_id).to eq(42)
    end
  end

  describe '#completed?' do
    it 'returns true for succeeded jobs' do
      expect(build(:job_log, :succeeded).completed?).to be(true)
    end

    it 'returns true for failed jobs' do
      expect(build(:job_log, :failed).completed?).to be(true)
    end

    it 'returns false for queued jobs' do
      expect(build(:job_log, status: 'queued').completed?).to be(false)
    end
  end

  describe '#stale?' do
    it 'returns true for running jobs older than the threshold' do
      job_log = build(:job_log, status: 'running', started_at: 20.minutes.ago)

      expect(job_log.stale?).to be(true)
    end

    it 'returns false for completed jobs' do
      job_log = build(:job_log, :succeeded, started_at: 20.minutes.ago)

      expect(job_log.stale?).to be(false)
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
