require 'rails_helper'

RSpec.describe Admin::JobMonitoringService do
  describe '#job_log_stats' do
    it 'summarizes the provided scope' do
      create(:job_log, status: 'running', started_at: 20.minutes.ago, finished_at: nil, duration_ms: nil)
      create(:job_log, :succeeded, duration_ms: 1_500, finished_at: 20.minutes.ago)
      create(:job_log, :failed, duration_ms: 500, finished_at: 10.minutes.ago)

      stats = described_class.new.job_log_stats(JobLog.all)

      expect(stats.total).to eq(3)
      expect(stats.running).to eq(1)
      expect(stats.completed).to eq(2)
      expect(stats.failed).to eq(1)
      expect(stats.failure_rate).to eq(50.0)
      expect(stats.average_duration_seconds).to eq(1.0)
      expect(stats.completed_last_hour).to eq(2)
      expect(stats.stale_running).to eq(1)
    end
  end

  describe '#queue_overview' do
    it 'returns an unavailable overview when queue tables are not available' do
      service = described_class.new

      allow(service).to receive(:queue_tables_available?).and_return(false)

      overview = service.queue_overview

      expect(overview).to be_unavailable
      expect(overview.error_message).to eq('Solid Queue runtime data is unavailable in this environment.')
    end
  end

  describe '#queue_snapshot_for' do
    it 'returns an unavailable snapshot when queue tables are not available' do
      service = described_class.new

      allow(service).to receive(:queue_tables_available?).and_return(false)

      snapshot = service.queue_snapshot_for('job-123')

      expect(snapshot).to be_unavailable
      expect(snapshot.state).to eq(:unavailable)
    end
  end
end
