require 'rails_helper'

RSpec.describe 'Passwords', type: :request do
  describe 'GET /passwords/new' do
    it 'renders the refined recovery surface' do
      get new_password_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Account recovery')
      expect(response.body).to include('Reset your password')
      expect(response.body).to include('What happens next')
      expect(response.body).to include('Back to sign in')
      expect(response.body).to include('atelier-pill')
    end

    it 'preserves locale query params through the sign-in handoff link' do
      get new_password_path(locale: :en)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(%(href="#{new_session_path(locale: :en)}"))
    end
  end

  describe 'GET /passwords/:token/edit' do
    it 'renders the refined password update surface for a valid token' do
      user = create(:user)

      get edit_password_path(token: user.generate_token_for(:password_reset), locale: :en)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Choose a new password')
      expect(response.body).to include('Account recovery')
      expect(response.body).to include('Request a new link')
      expect(response.body).to include('Save password')
      expect(response.body).to include(%(href="#{new_password_path(locale: :en)}"))
      expect(response.body).to include('atelier-pill')
    end

    it 'redirects to the recovery request with a localized alert when the token is invalid' do
      get edit_password_path(token: 'invalid-token')

      expect(response).to redirect_to(new_password_path)
      expect(flash[:alert]).to eq(I18n.t('passwords.controller.invalid_or_expired'))
    end
  end

  describe 'POST /passwords' do
    it 'redirects with a localized generic reset notice' do
      create(:user, email_address: 'person@example.com')

      post passwords_path(locale: :en), params: { email_address: 'person@example.com' }

      expect(response).to redirect_to(new_session_path(locale: :en))
      expect(flash[:notice]).to eq(I18n.t('passwords.controller.reset_sent'))
    end
  end

  describe 'PUT /passwords/:token' do
    it 'rerenders the form with an inline error when the passwords do not match' do
      user = create(:user)

      put password_path(token: user.generate_token_for(:password_reset)), params: {
        password: 'password123',
        password_confirmation: 'different-password'
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include('Password confirmation')
      expect(response.body).to include('Request a new link')
    end
  end
end
