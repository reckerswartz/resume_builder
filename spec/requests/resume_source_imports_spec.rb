require 'rails_helper'

RSpec.describe 'ResumeSourceImports', type: :request do
  let(:user) { create(:user) }

  before do
    sign_in_as(user)
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('GOOGLE_DRIVE_CLIENT_ID').and_return(nil)
    allow(ENV).to receive(:[]).with('GOOGLE_DRIVE_CLIENT_SECRET').and_return(nil)
    allow(ENV).to receive(:[]).with('DROPBOX_APP_KEY').and_return(nil)
    allow(ENV).to receive(:[]).with('DROPBOX_APP_SECRET').and_return(nil)
  end

  describe 'GET /resume_source_imports/:provider' do
    it 'renders the localized launch page for a valid provider in a resume context' do
      resume = create(:resume, user: user)

      get resume_source_import_path('google_drive'), params: {
        resume_id: resume.id,
        return_to: edit_resume_path(resume, step: 'source')
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(
        I18n.t(
          'resumes.resume_source_imports.show.page_header.title',
          provider: I18n.t('resumes.cloud_import_provider_catalog.providers.google_drive.label')
        )
      )
      expect(response.body).to include(I18n.t('resumes.cloud_import_provider_catalog.providers.google_drive.description'))
      expect(response.body).to include(I18n.t('resumes.resume_source_imports.show.page_header.safe_scaffold_badge'))
      expect(response.body).to include(
        I18n.t(
          'resumes.cloud_import_provider_catalog.feedback.setup_required',
          provider: I18n.t('resumes.cloud_import_provider_catalog.providers.google_drive.label'),
          env_vars: 'GOOGLE_DRIVE_CLIENT_ID and GOOGLE_DRIVE_CLIENT_SECRET'
        )
      )
      expect(response.body).to include(I18n.t('resumes.resume_source_imports.show.actions.back_to_source_step'))
      expect(response.body).to include(edit_resume_path(resume, step: 'source'))
      expect(response.body).to include(resume.title)
    end

    it 'falls back to the safe resume source path when return_to is not a safe internal path' do
      resume = create(:resume, user: user)

      get resume_source_import_path('google_drive'), params: {
        resume_id: resume.id,
        return_to: '//example.com/evil'
      }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(edit_resume_path(resume, step: 'source'))
      expect(response.body).not_to include('//example.com/evil')
    end

    it 'redirects with the localized provider-unavailable alert when the provider is unknown' do
      resume = create(:resume, user: user)

      get resume_source_import_path('unknown-provider'), params: {
        resume_id: resume.id
      }

      expect(response).to redirect_to(edit_resume_path(resume, step: 'source'))
      expect(flash[:alert]).to eq(I18n.t('resumes.resume_source_imports_controller.provider_unavailable'))
    end

    it 'redirects to the workspace with the localized resume-unavailable alert when the resume is missing' do
      get resume_source_import_path('google_drive'), params: {
        resume_id: Resume.maximum(:id).to_i + 1
      }

      expect(response).to redirect_to(resumes_path)
      expect(flash[:alert]).to eq(I18n.t('resumes.resume_source_imports_controller.resume_unavailable'))
    end

    it 'uses the setup return path when launched without a resume context' do
      get resume_source_import_path('dropbox')

      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.t('resumes.resume_source_imports.show.actions.back_to_resume_setup'))
      expect(response.body).to include(new_resume_path(step: 'setup'))
      expect(response.body).to include(I18n.t('resumes.resume_source_imports.show.provider_state.new_resume_setup'))
    end
  end
end
