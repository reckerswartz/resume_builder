require 'rails_helper'

RSpec.describe Admin::JobLogsIndexService do
  let(:admin) { create(:user, :admin) }

  before do
    allow(Pundit).to receive(:policy_scope!).and_call_original
  end

  def job_log_scope
    JobLog.all
  end

  def error_log_scope
    ErrorLog.all
  end

  def build_service(query: "", status_filter: "", sort: "created_at", direction: "desc", requested_page: 1, per_page: 20)
    described_class.new(
      job_log_scope: job_log_scope,
      error_log_scope: error_log_scope,
      query: query,
      status_filter: status_filter,
      sort: sort,
      direction: direction,
      requested_page: requested_page,
      per_page: per_page
    )
  end

  describe '#call' do
    it 'returns filtered job logs with stats and queue overview' do
      create(:job_log, :succeeded)
      create(:job_log, :failed)

      result = build_service.call

      expect(result.total_count).to eq(2)
      expect(result.job_logs.size).to eq(2)
      expect(result.job_log_stats).to be_a(Admin::JobMonitoringService::JobLogStats)
      expect(result.queue_overview).to be_a(Admin::JobMonitoringService::QueueOverview)
      expect(result.related_error_logs).to eq({})
    end

    it 'applies status filtering' do
      create(:job_log, :succeeded)
      create(:job_log, :failed)

      result = build_service(status_filter: "failed").call

      expect(result.total_count).to eq(1)
      expect(result.job_logs.first).to be_failed
    end

    it 'applies query filtering' do
      create(:job_log, job_type: 'ResumeExportJob')
      create(:job_log, job_type: 'PhotoNormalizeJob')

      result = build_service(query: "Resume").call

      expect(result.total_count).to eq(1)
      expect(result.job_logs.first.job_type).to eq('ResumeExportJob')
    end

    it 'finds an exact match by active_job_id independently of status filter' do
      matching = create(:job_log, :succeeded, active_job_id: 'exact-id-123')
      create(:job_log, :failed)

      result = build_service(query: 'exact-id-123', status_filter: 'failed').call

      expect(result.exact_match_job_log).to eq(matching)
      expect(result.job_logs).not_to include(matching)
    end

    it 'returns nil exact_match_job_log when query is blank' do
      create(:job_log, :succeeded)

      result = build_service(query: "").call

      expect(result.exact_match_job_log).to be_nil
    end

    it 'preloads related error logs for job rows with references' do
      job_with_error = create(:job_log, :failed, error_details: { 'reference_id' => 'ERR-001' })
      error_log = create(:error_log, :job, reference_id: 'ERR-001')
      create(:job_log, :failed, error_details: {})

      result = build_service.call

      expect(result.related_error_logs['ERR-001']).to eq(error_log)
      expect(result.related_error_logs.size).to eq(1)
    end

    it 'paginates results' do
      3.times { create(:job_log, :succeeded) }

      result = build_service(per_page: 2, requested_page: 1).call

      expect(result.total_count).to eq(3)
      expect(result.total_pages).to eq(2)
      expect(result.current_page).to eq(1)
      expect(result.job_logs.size).to eq(2)
    end

    it 'clamps the requested page to the valid range' do
      create(:job_log, :succeeded)

      result = build_service(per_page: 20, requested_page: 999).call

      expect(result.current_page).to eq(1)
    end
  end
end
