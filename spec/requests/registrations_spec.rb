require 'rails_helper'

RSpec.describe 'Registrations', type: :request do
  before do
    create(:template)
  end

  describe 'GET /registration/new' do
    it 'renders the refined registration surface' do
      get new_registration_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Workspace setup')
      expect(response.body).to include('Start with a draft you can shape right away.')
      expect(response.body).to include('Starter draft included')
      expect(response.body).to include('What you get right away')
      expect(response.body).to include('Already have an account?')
      expect(response.body).to include('atelier-pill')
    end

    it 'preserves locale query params through the sign-in handoff link' do
      get new_registration_path(locale: :en)

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(%(href="#{new_session_path(locale: :en)}"))
    end
  end

  describe 'POST /registration' do
    it 'creates a user and starter resume' do
      expect do
        post registration_path(locale: :en), params: {
          user: {
            email_address: 'new-user@example.com',
            password: 'password123',
            password_confirmation: 'password123'
          }
        }
      end.to change(User, :count).by(1)

      expect(Resume.count).to eq(1)
      expect(Resume.last.sections.count).to eq(ResumeBuilder::SectionRegistry.starter_sections.size)
      expect(User.last).to be_admin
      expect(response).to redirect_to(resumes_path(locale: :en))
      expect(flash[:notice]).to eq(I18n.t('registrations.controller.workspace_ready'))
    end
  end
end
