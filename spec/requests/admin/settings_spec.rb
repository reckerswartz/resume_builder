require 'rails_helper'

RSpec.describe 'Admin::Settings', type: :request do
  let!(:platform_setting) { PlatformSetting.current }

  before do
    sign_in_as(create(:user, :admin))
  end

  describe 'PATCH /admin/settings' do
    it 'updates feature flags and preferences' do
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
        }
      }

      expect(response).to redirect_to(admin_settings_path)
      expect(platform_setting.reload.feature_enabled?('llm_access')).to eq(true)
      expect(platform_setting.preferences['default_template_slug']).to eq('classic')
    end
  end
end
