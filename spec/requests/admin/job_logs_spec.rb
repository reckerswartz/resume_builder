require 'cgi'
require 'rails_helper'

RSpec.describe 'Admin::JobLogs', type: :request do
  before do
    sign_in_as(create(:user, :admin))
  end

  describe 'GET /admin/job_logs' do
    it 'renders successfully' do
      create(:job_log, :succeeded)

      get admin_job_logs_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Job logs')
      expect(response.body).to include('Filter job logs')
      expect(response.body).to include('Jobs in scope')
      expect(response.body).to include('Failure rate')
      expect(response.body).to include('Average runtime')
      expect(response.body).to include('Find a job by reference')
      expect(response.body).to include('Queue overview')
      expect(response.body).to include('Queue health data is unavailable in this environment.')
      expect(response.body).not_to include('Paste an Active Job ID')
      expect(response.body).not_to include('Solid Queue overview')
      expect(response.body).not_to include('active_job_id')
      expect(response.body).to include('page-header-compact')
    end

    it 'shows an operator-facing fallback when a job reference was not recorded' do
      create(:job_log, active_job_id: nil)

      get admin_job_logs_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('No job reference recorded')
      expect(response.body).not_to include('No active job id')
    end

    it 'renders inline related error summaries for job rows' do
      linked_job = create(
        :job_log,
        :failed,
        active_job_id: 'job-123',
        error_details: {
          'reference_id' => 'ERR-JOB-0001',
          'message' => 'Something went wrong'
        }
      )
      create(
        :error_log,
        :job,
        reference_id: 'ERR-JOB-0001',
        context: {
          'active_job_id' => linked_job.active_job_id,
          'job_type' => linked_job.job_type,
          'queue_name' => linked_job.queue_name,
          'job_log_id' => linked_job.id
        }
      )
      create(:job_log, :failed, active_job_id: 'job-456', error_details: {})

      get admin_job_logs_path
      response_body = CGI.unescapeHTML(response.body)

      expect(response).to have_http_status(:ok)
      expect(response_body).to include('ERR-JOB-0001')
      expect(response_body).to include('Open related error')
      expect(response_body).to include('Captured error details are available for full context and backtrace review.')
      expect(response_body).to include('No error reference')
      expect(response_body).to include('This failed job did not capture a related error reference.')
    end

    it 'filters and sorts job logs' do
      create(:job_log, job_type: 'AlphaImportJob', queue_name: 'imports', status: 'failed')
      create(:job_log, job_type: 'ResumeExportJob', queue_name: 'exports', status: 'succeeded')
      create(:job_log, job_type: 'ZetaImportJob', queue_name: 'imports', status: 'failed')

      get admin_job_logs_path, params: {
        query: 'import',
        status: 'failed',
        sort: 'job_type',
        direction: 'desc'
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('ZetaImportJob')
      expect(response.body).to include('AlphaImportJob')
      expect(response.body).not_to include('ResumeExportJob')
      expect(response.body.index('ZetaImportJob')).to be < response.body.index('AlphaImportJob')
    end

    it 'shows an exact match for an active job id even when the table filter excludes it' do
      matching_job = create(:job_log, :succeeded, active_job_id: 'job-lookup-123', job_type: 'ResumeExportJob')
      create(:job_log, :failed, active_job_id: 'job-lookup-999', job_type: 'OtherJob')

      get admin_job_logs_path, params: {
        query: 'job-lookup-123',
        status: 'failed'
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Find a job by reference')
      expect(response.body).to include(matching_job.active_job_id)
      expect(response.body).to include('Open detail')
    end
  end

  describe 'GET /admin/job_logs/:id' do
    it 'renders the grouped job hub with queue controls and related error guidance' do
      job_log = create(:job_log, :failed, error_details: { 'reference_id' => 'ERR-JOB-0001', 'message' => 'Something went wrong' })
      create(
        :error_log,
        :job,
        reference_id: 'ERR-JOB-0001',
        context: {
          'active_job_id' => job_log.active_job_id,
          'job_type' => job_log.job_type,
          'queue_name' => job_log.queue_name,
          'job_log_id' => job_log.id
        }
      )

      get admin_job_log_path(job_log)
      response_body = CGI.unescapeHTML(response.body)

      expect(response).to have_http_status(:ok)
      expect(response_body).to include(job_log.job_type)
      expect(response_body).to include('Review this job')
      expect(response_body).to include('Follow-up actions')
      expect(response_body).to include('Live queue status')
      expect(response_body).to include('Captured payloads')
      expect(response_body).to include('Safe actions')
      expect(response_body).to include('Lifecycle and worker details')
      expect(response_body).to include('Open related error')
    end

    it 'renders succeeded logs without raising an error' do
      job_log = create(:job_log, :succeeded)

      get admin_job_log_path(job_log)
      response_body = CGI.unescapeHTML(response.body)

      expect(response).to have_http_status(:ok)
      expect(response_body).to include(job_log.job_type)
      expect(response_body).to include('Succeeded')
      expect(response_body).to include('Live queue status')
    end
  end

  describe 'POST /admin/job_logs/:id/retry' do
    it 'redirects with a notice when the retry succeeds' do
      job_log = create(:job_log, :failed)
      result = Admin::JobControlService::Result.new(success: true, message: 'Retry requested.', redirect_job_log: job_log)
      service = instance_double(Admin::JobControlService, retry: result)

      allow(Admin::JobControlService).to receive(:new).with(job_log: job_log).and_return(service)

      post retry_admin_job_log_path(job_log)

      expect(response).to redirect_to(admin_job_log_path(job_log))
      expect(flash[:notice]).to eq('Retry requested.')
    end
  end

  describe 'POST /admin/job_logs/:id/discard' do
    it 'redirects with an alert when the discard is rejected' do
      job_log = create(:job_log, status: 'running')
      result = Admin::JobControlService::Result.new(success: false, message: 'Discard is not safe right now.', redirect_job_log: job_log)
      service = instance_double(Admin::JobControlService, discard: result)

      allow(Admin::JobControlService).to receive(:new).with(job_log: job_log).and_return(service)

      post discard_admin_job_log_path(job_log)

      expect(response).to redirect_to(admin_job_log_path(job_log))
      expect(flash[:alert]).to eq('Discard is not safe right now.')
    end
  end

  describe 'POST /admin/job_logs/:id/requeue' do
    it 'requeues a failed job as a fresh admin-tracked job' do
      ActiveJob::Base.queue_adapter.enqueued_jobs.clear
      job_log = create(:job_log, :failed, job_type: 'ResumeExportJob', queue_name: 'default', input: { 'arguments' => [ 1, 2 ] })

      expect do
        post requeue_admin_job_log_path(job_log)
      end.to change(ActiveJob::Base.queue_adapter.enqueued_jobs, :size).by(1)
        .and change(JobLog, :count).by(1)

      redirected_job_log = JobLog.order(:created_at).last

      expect(response).to redirect_to(admin_job_log_path(redirected_job_log))
      expect(flash[:notice]).to include('Requeued as a new job')
      expect(redirected_job_log.active_job_id).not_to eq(job_log.active_job_id)
    end
  end
end
