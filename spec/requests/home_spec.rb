require 'rails_helper'

RSpec.describe 'Home', type: :request do
  describe 'GET /' do
    it 'renders successfully for unauthenticated visitors' do
      get root_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Create account')
      expect(response.body).to include('See how it works')
      expect(response.body).to include('Three simple ways to begin')
      expect(response.body).to include('Common questions')
      expect(response.body).to include('atelier-pill')
    end

    it 'redirects authenticated users to resumes' do
      user = create(:user)
      sign_in_as(user)

      get root_path

      expect(response).to redirect_to(resumes_path)
    end
  end
end
