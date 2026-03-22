require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  describe 'GET /session/new' do
    it 'renders the refined sign-in surface for unauthenticated visitors' do
      get new_session_path

      expect(response).to have_http_status(:ok)
      document = Nokogiri::HTML.parse(response.body)

      expect(response.body).to include('Secure sign in')
      expect(response.body).to include('Return to your drafts')
      expect(response.body).to include('Forgot password?')
      expect(response.body).to include('Need an account?')
      expect(response.body).to include('atelier-pill')

      expect(response.body).not_to include('Sign in to continue.')

      form_heading = document.at_css('h2')
      expect(form_heading.text.strip).to eq(I18n.t('sessions.new.form.title'))
    end

    it 'preserves locale query params through sign-in recovery links' do
      get new_session_path(locale: :en)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(%(href="#{new_password_path(locale: :en)}"))
      expect(response.body).to include(%(href="#{new_registration_path(locale: :en)}"))
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

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include(I18n.t('sessions.controller.invalid_credentials'))
      expect(response.body).to include('Caps lock is on.')
    end
  end
end
