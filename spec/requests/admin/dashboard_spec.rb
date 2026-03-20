require 'rails_helper'

RSpec.describe 'Admin::Dashboard', type: :request do
  describe 'GET /admin' do
    it 'redirects non-admin users away from the dashboard' do
      sign_in_as(create(:user))

      get admin_root_path

      expect(response).to redirect_to(resumes_path)
    end

    it 'renders the grouped admin dashboard hub for admins' do
      sign_in_as(create(:user, :admin))
      create(:job_log, :failed, job_type: 'ResumeExportJob')
      create(:error_log, :job, reference_id: 'ERR-SEED-0001')

      get admin_root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Admin hub')
      expect(response.body).to include('Dashboard')
      expect(response.body).to include('Logged errors')
      expect(response.body).to include('Quick links')
      expect(response.body).to include('Jump straight to the area that needs attention')
      expect(response.body).to include('Investigate')
      expect(response.body).to include('Needs follow-up')
      expect(response.body).to include('Runtime and queue health')
      expect(response.body).to include('Operational focus')
      expect(response.body).to include('Recent job activity')
      expect(response.body).to include('Recent error activity')
      expect(response.body).to include('ResumeExportJob')
      expect(response.body).to include('ERR-SEED-0001')
      expect(response.body).to include('atelier-hero-compact')
      expect(response.body).to include('dashboard-panel-compact')
    end
  end
end
