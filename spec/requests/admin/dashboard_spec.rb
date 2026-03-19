require 'rails_helper'

RSpec.describe 'Admin::Dashboard', type: :request do
  describe 'GET /admin' do
    it 'redirects non-admin users away from the dashboard' do
      sign_in_as(create(:user))

      get admin_root_path

      expect(response).to redirect_to(resumes_path)
    end

    it 'renders successfully for admins' do
      sign_in_as(create(:user, :admin))

      get admin_root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Dashboard')
    end
  end
end
