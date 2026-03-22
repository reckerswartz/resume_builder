require 'cgi'
require 'rails_helper'

RSpec.describe 'Admin::ErrorLogs', type: :request do
  before do
    sign_in_as(create(:user, :admin))
  end

  describe 'GET /admin/error_logs' do
    it 'renders successfully' do
      create(:error_log)

      get admin_error_logs_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Error logs')
      expect(response.body).to include('Filter error logs')
      expect(response.body).to include('Errors in scope')
      expect(response.body).to include('Backtrace coverage')
      expect(response.body).to include('Correlation guide')
      expect(response.body).to include('Search by error or job reference')
      expect(response.body).to include('Page and job signals')
      expect(response.body).not_to include('Search by reference or runtime IDs')
      expect(response.body).not_to include('request-cycle')
      expect(response.body).to include('page-header-compact')
    end

    it 'renders correlation and source summaries for request and job rows' do
      create(
        :error_log,
        reference_id: 'ERR-REQ-001',
        duration_ms: 210,
        context: {
          'request_id' => 'req-123',
          'path' => '/resumes',
          'method' => 'GET',
          'user_id' => 1
        }
      )
      create(
        :error_log,
        :job,
        reference_id: 'ERR-JOB-001',
        duration_ms: nil,
        context: {
          'active_job_id' => 'job-123',
          'job_type' => 'ResumeExportJob',
          'queue_name' => 'default',
          'job_log_id' => 1
        }
      )

      get admin_error_logs_path
      response_body = CGI.unescapeHTML(response.body)

      expect(response).to have_http_status(:ok)
      expect(response_body).to include('req-123')
      expect(response_body).to include('GET /resumes · User 1')
      expect(response_body).to include('Captured during a page request with safe path and signed-in user details when available.')
      expect(response_body).to include('job-123')
      expect(response_body).to include('ResumeExportJob · Queue: default')
      expect(response_body).to include('Captured during background processing with related job details when available.')
      expect(response_body).to include('0.21 seconds')
      expect(response_body).to include('N/A')
    end

    it 'filters and sorts error logs' do
      create(:error_log, reference_id: 'ERR-ALPHA', source: 'request', error_class: 'AlphaError')
      create(:error_log, :job, reference_id: 'ERR-VISION', error_class: 'VisionError')
      create(:error_log, :job, reference_id: 'ERR-ZETA', error_class: 'ZetaError')

      get admin_error_logs_path, params: {
        query: 'ERR-',
        source: 'job',
        sort: 'reference_id',
        direction: 'desc'
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('ERR-ZETA')
      expect(response.body).to include('ERR-VISION')
      expect(response.body).not_to include('ERR-ALPHA')
      expect(response.body.index('ERR-ZETA')).to be < response.body.index('ERR-VISION')
    end
  end

  describe 'GET /admin/error_logs/:id' do
    it 'renders the grouped error hub with related job guidance' do
      job_log = create(:job_log, :failed, active_job_id: 'job-123')
      error_log = create(
        :error_log,
        :job,
        reference_id: 'ERR-JOB-123',
        context: {
          'active_job_id' => job_log.active_job_id,
          'job_type' => job_log.job_type,
          'queue_name' => job_log.queue_name,
          'job_log_id' => job_log.id
        }
      )

      get admin_error_log_path(error_log)
      response_body = CGI.unescapeHTML(response.body)

      expect(response).to have_http_status(:ok)
      expect(response_body).to include(error_log.reference_id)
      expect(response_body).to include('Review this error')
      expect(response_body).to include('Incident summary')
      expect(response_body).to include('Captured context')
      expect(response_body).to include('Backtrace')
      expect(response_body).to include('Captured issue')
      expect(response_body).to include('Structured details')
      expect(response_body).to include('Job reference')
      expect(response_body).to include('Open related job log')
      expect(response_body).not_to include('Request-cycle failure')
      expect(response_body).not_to include('Active job ID')
    end

    it 'renders request-sourced logs without a backtrace' do
      error_log = create(
        :error_log,
        reference_id: 'ERR-REQ-123',
        source: 'request',
        context: {
          'request_id' => 'req-123',
          'path' => '/resumes',
          'method' => 'GET',
          'user_id' => 7
        },
        backtrace_lines: []
      )

      get admin_error_log_path(error_log)
      response_body = CGI.unescapeHTML(response.body)

      expect(response).to have_http_status(:ok)
      expect(response_body).to include(error_log.reference_id)
      expect(response_body).to include('Page request')
      expect(response_body).to include('Request reference')
      expect(response_body).to include('No backtrace')
      expect(response_body).not_to include('Request ID')
    end
  end
end
