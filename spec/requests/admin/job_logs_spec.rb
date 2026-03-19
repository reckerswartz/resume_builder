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
    end
  end

  describe 'GET /admin/job_logs/:id' do
    it 'renders the selected log' do
      job_log = create(:job_log, :failed)

      get admin_job_log_path(job_log)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(job_log.job_type)
    end
  end
end
