require 'rails_helper'

RSpec.describe Admin::JobControlService do
  describe '#retry' do
    it 'retries a failed queue execution' do
      job_log = create(:job_log, :failed)
      failed_execution = double('failed_execution')
      snapshot = Admin::JobMonitoringService::QueueSnapshot.new(
        available: true,
        job: nil,
        state: :failed,
        ready_execution: nil,
        claimed_execution: nil,
        failed_execution: failed_execution,
        scheduled_execution: nil,
        blocked_execution: nil,
        process: nil,
        error_message: nil
      )

      allow(failed_execution).to receive(:retry)

      result = described_class.new(job_log: job_log, queue_snapshot: snapshot).retry

      expect(result).to be_success
      expect(result.message).to include(job_log.active_job_id)
      expect(failed_execution).to have_received(:retry)
    end
  end

  describe '#discard' do
    it 'discards a queued execution and marks the job log as failed' do
      job_log = create(:job_log, status: 'queued', finished_at: nil, error_details: {})
      ready_execution = double('ready_execution')
      snapshot = Admin::JobMonitoringService::QueueSnapshot.new(
        available: true,
        job: nil,
        state: :queued,
        ready_execution: ready_execution,
        claimed_execution: nil,
        failed_execution: nil,
        scheduled_execution: nil,
        blocked_execution: nil,
        process: nil,
        error_message: nil
      )

      allow(ready_execution).to receive(:discard)

      result = described_class.new(job_log: job_log, queue_snapshot: snapshot).discard

      expect(result).to be_success
      expect(ready_execution).to have_received(:discard)
      expect(job_log.reload).to be_failed
      expect(job_log.error_details.dig('admin_action', 'action')).to eq('discard')
    end
  end

  describe '#requeue' do
    before do
      ActiveJob::Base.queue_adapter.enqueued_jobs.clear
    end

    it 'requeues a failed job as a fresh enqueue' do
      job_log = create(:job_log, :failed, job_type: 'ResumeExportJob', queue_name: 'default', input: { 'arguments' => [ 1, 2 ] })
      snapshot = Admin::JobMonitoringService::QueueSnapshot.new(
        available: false,
        job: nil,
        state: :unavailable,
        ready_execution: nil,
        claimed_execution: nil,
        failed_execution: nil,
        scheduled_execution: nil,
        blocked_execution: nil,
        process: nil,
        error_message: 'queue unavailable'
      )

      expect do
        @result = described_class.new(job_log: job_log, queue_snapshot: snapshot).requeue
      end.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
        .and change(JobLog, :count).by(1)

      expect(@result).to be_success
      expect(@result.message).to include('Requeued as a new job')
      expect(@result.redirect_job_log.active_job_id).not_to eq(job_log.active_job_id)
    end

    it 'returns an orphaned running job to the ready queue' do
      job_log = create(:job_log, status: 'running', started_at: 20.minutes.ago, finished_at: nil)
      claimed_execution = double('claimed_execution')
      snapshot = Admin::JobMonitoringService::QueueSnapshot.new(
        available: true,
        job: nil,
        state: :running,
        ready_execution: nil,
        claimed_execution: claimed_execution,
        failed_execution: nil,
        scheduled_execution: nil,
        blocked_execution: nil,
        process: nil,
        error_message: nil
      )

      allow(claimed_execution).to receive(:release)

      result = described_class.new(job_log: job_log, queue_snapshot: snapshot).requeue

      expect(result).to be_success
      expect(result.message).to include('returned to the ready queue')
      expect(claimed_execution).to have_received(:release)
    end
  end
end
