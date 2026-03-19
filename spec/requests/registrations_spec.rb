require 'rails_helper'

RSpec.describe 'Registrations', type: :request do
  before do
    create(:template, slug: 'modern')
  end

  describe 'GET /registration/new' do
    it 'renders successfully' do
      get new_registration_path

      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /registration' do
    it 'creates a user and starter resume' do
      expect do
        post registration_path, params: {
          user: {
            email_address: 'new-user@example.com',
            password: 'password123',
            password_confirmation: 'password123'
          }
        }
      end.to change(User, :count).by(1)

      expect(Resume.count).to eq(1)
      expect(Resume.last.sections.count).to eq(4)
      expect(response).to redirect_to(resumes_path)
    end
  end
end
