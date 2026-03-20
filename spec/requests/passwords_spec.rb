require 'rails_helper'

RSpec.describe 'Passwords', type: :request do
  describe 'GET /passwords/new' do
    it 'renders the refined recovery surface' do
      get new_password_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Account recovery')
      expect(response.body).to include('Reset your password')
      expect(response.body).to include('What happens next')
      expect(response.body).to include('atelier-pill')
    end
  end

  describe 'GET /passwords/:token/edit' do
    it 'renders the refined password update surface for a valid token' do
      user = create(:user)

      get edit_password_path(user.generate_token_for(:password_reset))

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Choose a new password')
      expect(response.body).to include('Account recovery')
      expect(response.body).to include('Request a new link')
      expect(response.body).to include('atelier-pill')
    end
  end

  describe 'PUT /passwords/:token' do
    it 'rerenders the form with an inline error when the passwords do not match' do
      user = create(:user)

      put password_path(user.generate_token_for(:password_reset)), params: {
        password: 'password123',
        password_confirmation: 'different-password'
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include('Password confirmation')
      expect(response.body).to include('Request a new link')
    end
  end
end
