require 'rails_helper'

RSpec.describe Admin::SettingsUpdateService do
  let!(:platform_setting) { PlatformSetting.current }
  let!(:text_model) { create(:llm_model, identifier: 'text-model') }
  let!(:second_text_model) { create(:llm_model, identifier: 'text-model-2') }
  let!(:vision_model) { create(:llm_model, :vision_capable, identifier: 'vision-model') }

  describe '#call' do
    it 'updates platform settings and role assignments when the input is valid' do
      result = described_class.new(
        platform_setting: platform_setting,
        platform_setting_params: {
          feature_flags: {
            'llm_access' => true,
            'resume_suggestions' => true,
            'autofill_content' => false,
            'photo_processing' => true,
            'resume_image_generation' => false
          },
          preferences: {
            'default_template_slug' => 'classic',
            'support_email' => 'support@resume.test'
          }
        },
        role_model_ids: {
          'text_generation' => [ text_model.id.to_s ],
          'text_verification' => [ text_model.id.to_s ],
          'vision_generation' => [ vision_model.id.to_s ],
          'vision_verification' => [ vision_model.id.to_s ]
        }
      ).call

      expect(result).to be_success
      expect(result.platform_setting).to eq(platform_setting)
      expect(platform_setting.reload.feature_enabled?('llm_access')).to eq(true)
      expect(platform_setting.feature_enabled?('photo_processing')).to eq(true)
      expect(platform_setting.preferences['default_template_slug']).to eq('classic')
      expect(LlmModelAssignment.for_role('text_generation').pluck(:llm_model_id)).to eq([ text_model.id ])
      expect(LlmModelAssignment.for_role('vision_generation').pluck(:llm_model_id)).to eq([ vision_model.id ])
    end

    it 'merges role assignment errors onto the platform setting and rolls back the settings update when assignments are invalid' do
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

      result = described_class.new(
        platform_setting: platform_setting,
        platform_setting_params: {
          feature_flags: {
            'llm_access' => true,
            'resume_suggestions' => true,
            'autofill_content' => false,
            'photo_processing' => true,
            'resume_image_generation' => false
          },
          preferences: {
            'default_template_slug' => 'classic',
            'support_email' => 'support@resume.test'
          }
        },
        role_model_ids: {
          'text_generation' => [ text_model.id.to_s, second_text_model.id.to_s ],
          'text_verification' => [ text_model.id.to_s ]
        }
      ).call

      expect(result).not_to be_success
      expect(result.platform_setting.errors.full_messages).to include('Text generation can only have one primary model.')
      expect(platform_setting.reload.feature_enabled?('llm_access')).to eq(false)
      expect(platform_setting.preferences['default_template_slug']).to eq('modern')
      expect(LlmModelAssignment.count).to eq(0)
    end
  end
end
