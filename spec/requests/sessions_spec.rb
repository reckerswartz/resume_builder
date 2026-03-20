require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  describe 'GET /session/new' do
    it 'renders the refined sign-in surface for unauthenticated visitors' do
      get new_session_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Secure sign in')
      expect(response.body).to include('Pick up where you left off.')
      expect(response.body).to include('Return to your drafts')
      expect(response.body).to include('atelier-pill')
    end
  end

  describe 'POST /session' do
    it 'authenticates with valid credentials' do
      user = create(:user, email_address: 'person@example.com', password: 'password123')

      post session_path, params: {
        email_address: user.email_address,
        password: 'password123'
      }

      expect(response).to redirect_to(root_url)
    end

    it 'rerenders with an inline error for invalid credentials' do
      create(:user, email_address: 'person@example.com', password: 'password123')

      post session_path, params: {
        email_address: 'person@example.com',
        password: 'wrong-password'
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include('Try another email address or password.')
      expect(response.body).to include('Caps lock is on.')
    end
  end
end
