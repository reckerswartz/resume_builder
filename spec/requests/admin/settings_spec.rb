require 'rails_helper'

RSpec.describe 'Admin::Settings', type: :request do
  let!(:platform_setting) { PlatformSetting.current }
  let!(:text_model) { create(:llm_model, identifier: 'text-model') }
  let!(:vision_model) { create(:llm_model, :vision_capable, identifier: 'vision-model') }

  before do
    sign_in_as(create(:user, :admin))
  end

  describe 'GET /admin/settings' do
    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('GOOGLE_DRIVE_CLIENT_ID').and_return(nil)
      allow(ENV).to receive(:[]).with('GOOGLE_DRIVE_CLIENT_SECRET').and_return(nil)
      allow(ENV).to receive(:[]).with('DROPBOX_APP_KEY').and_return(nil)
      allow(ENV).to receive(:[]).with('DROPBOX_APP_SECRET').and_return(nil)
    end

    it 'renders the grouped settings hub' do
      get admin_settings_path

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Platform settings')
      expect(response.body).to include('Manage templates')
      expect(response.body).to include('Settings sections')
      expect(response.body).to include('Jump to the grouped controls')
      expect(response.body).to include('Settings summary')
      expect(response.body).to include('Workflow readiness')
      expect(response.body).to include('Feature access')
      expect(response.body).to include('Platform defaults')
      expect(response.body).to include('Cloud import connectors')
      expect(response.body).to include('Provider readiness')
      expect(response.body).to include('LLM orchestration')
      expect(response.body).to include('0/2 configured')
      expect(response.body).to include('Google Drive')
      expect(response.body).to include('Dropbox')
      expect(response.body).to include('Required environment variables')
      expect(response.body).to include('GOOGLE_DRIVE_CLIENT_ID')
      expect(response.body).to include('DROPBOX_APP_KEY')
      expect(response.body).to include('Save settings')
      expect(response.body).to include('page-header-compact')
      expect(response.body).to include('dashboard-panel-compact')
      expect(response.body).to include('sticky-action-bar-compact')
    end
  end

  describe 'PATCH /admin/settings' do
    it 'updates feature flags, preferences, and llm role assignments' do
      patch admin_settings_path, params: {
        platform_setting: {
          feature_flags: {
            llm_access: 'true',
            resume_suggestions: 'true',
            autofill_content: 'false'
          },
          preferences: {
            default_template_slug: 'classic',
            support_email: 'support@resume.test'
          }
        },
        llm_role_assignments: {
          text_generation: [ text_model.id.to_s ],
          text_verification: [ text_model.id.to_s ],
          vision_generation: [ vision_model.id.to_s ],
          vision_verification: [ vision_model.id.to_s ]
        }
      }

      expect(response).to redirect_to(admin_settings_path)
      expect(platform_setting.reload.feature_enabled?('llm_access')).to eq(true)
      expect(platform_setting.preferences['default_template_slug']).to eq('classic')
      expect(LlmModelAssignment.for_role('text_generation').pluck(:llm_model_id)).to eq([ text_model.id ])
      expect(LlmModelAssignment.for_role('text_verification').pluck(:llm_model_id)).to eq([ text_model.id ])
      expect(LlmModelAssignment.for_role('vision_generation').pluck(:llm_model_id)).to eq([ vision_model.id ])
      expect(LlmModelAssignment.for_role('vision_verification').pluck(:llm_model_id)).to eq([ vision_model.id ])
    end
  end
end
