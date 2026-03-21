require 'rails_helper'

RSpec.describe 'Admin::Settings', type: :request do
  let!(:platform_setting) { PlatformSetting.current }
  let!(:text_model) { create(:llm_model, identifier: 'text-model') }
  let!(:second_text_model) { create(:llm_model, identifier: 'text-model-2') }
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
      expect(response.body).to include(I18n.t('admin.settings_page_state.page_header.title'))
      expect(response.body).to include(I18n.t('admin.settings_page_state.page_header.actions.manage_templates'))
      expect(response.body).to include(I18n.t('admin.settings.show.navigation.eyebrow'))
      expect(response.body).to include(I18n.t('admin.settings.show.navigation.title'))
      expect(response.body).to include(I18n.t('admin.settings.show.summary.eyebrow'))
      expect(response.body).to include(I18n.t('admin.settings.show.summary.readiness_badge'))
      expect(response.body).to include(I18n.t('admin.settings.show.summary.save_posture.follow_up'))
      expect(response.body).to include(I18n.t('admin.settings.show.sections.feature_access.title'))
      expect(response.body).to include(I18n.t('admin.settings.show.sections.platform_defaults.title'))
      expect(response.body).to include(I18n.t('admin.settings.show.sections.cloud_import_connectors.title'))
      expect(response.body).to include(I18n.t('admin.settings.show.sections.cloud_import_connectors.eyebrow'))
      expect(response.body).to include(I18n.t('admin.settings.show.sections.llm_orchestration.title'))
      expect(response.body).to include(I18n.t('admin.settings_helper.feature_flags.photo_processing.label'))
      expect(response.body).to include(I18n.t('admin.settings_helper.feature_flags.resume_image_generation.label'))
      expect(response.body).to include('0/2 configured')
      expect(response.body).to include(I18n.t('resumes.cloud_import_provider_catalog.providers.google_drive.label'))
      expect(response.body).to include(I18n.t('resumes.cloud_import_provider_catalog.providers.google_drive.description'))
      expect(response.body).to include(I18n.t('resumes.cloud_import_provider_catalog.providers.dropbox.label'))
      expect(response.body).to include(I18n.t('resumes.cloud_import_provider_catalog.providers.dropbox.description'))
      expect(response.body).to include(I18n.t('admin.settings.show.sections.cloud_import_connectors.required_env_vars'))
      expect(response.body).to include('GOOGLE_DRIVE_CLIENT_ID')
      expect(response.body).to include('DROPBOX_APP_KEY')
      expect(response.body).to include(I18n.t('admin.settings.show.sticky_action_bar.title'))
      expect(response.body).to include(I18n.t('admin.settings.show.sticky_action_bar.actions.save_settings'))
      expect(response.body).not_to include('Translation missing:')
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
            autofill_content: 'false',
            photo_processing: 'true',
            resume_image_generation: 'false'
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
      expect(platform_setting.feature_enabled?('photo_processing')).to eq(true)
      expect(platform_setting.feature_enabled?('resume_image_generation')).to eq(false)
      expect(platform_setting.preferences['default_template_slug']).to eq('classic')
      expect(LlmModelAssignment.for_role('text_generation').pluck(:llm_model_id)).to eq([ text_model.id ])
      expect(LlmModelAssignment.for_role('text_verification').pluck(:llm_model_id)).to eq([ text_model.id ])
      expect(LlmModelAssignment.for_role('vision_generation').pluck(:llm_model_id)).to eq([ vision_model.id ])
      expect(LlmModelAssignment.for_role('vision_verification').pluck(:llm_model_id)).to eq([ vision_model.id ])
    end

    it 'rerenders the settings page and rolls back the platform update when role assignments are invalid' do
      platform_setting.update!(
        feature_flags: {
          'llm_access' => false,
          'resume_suggestions' => false,
          'autofill_content' => false,
          'photo_processing' => false,
          'resume_image_generation' => false
        },
        preferences: {
          'default_template_slug' => 'modern',
          'support_email' => 'support@example.com'
        }
      )

      patch admin_settings_path, params: {
        platform_setting: {
          feature_flags: {
            llm_access: 'true',
            resume_suggestions: 'true',
            autofill_content: 'false',
            photo_processing: 'true',
            resume_image_generation: 'false'
          },
          preferences: {
            default_template_slug: 'classic',
            support_email: 'support@resume.test'
          }
        },
        llm_role_assignments: {
          text_generation: [ text_model.id.to_s, second_text_model.id.to_s ],
          text_verification: [ text_model.id.to_s ]
        }
      }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.body).to include('Text generation can only have one primary model.')
      expect(response.body).to include(I18n.t('admin.settings_page_state.page_header.title'))
      expect(platform_setting.reload.feature_enabled?('llm_access')).to eq(false)
      expect(platform_setting.preferences['default_template_slug']).to eq('modern')
      expect(LlmModelAssignment.count).to eq(0)
    end
  end
end
