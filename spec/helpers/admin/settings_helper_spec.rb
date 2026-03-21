require 'rails_helper'

RSpec.describe Admin::SettingsHelper, type: :helper do
  describe '#feature_flags_for_settings' do
    it 'builds localized labels and descriptions for the settings toggles' do
      platform_setting = create(:platform_setting, feature_flags: { 'llm_access' => true, 'resume_suggestions' => false, 'autofill_content' => false, 'photo_processing' => true, 'resume_image_generation' => false })

      feature_flags = helper.feature_flags_for_settings(platform_setting)

      expect(feature_flags).to include(
        hash_including(
          key: 'llm_access',
          label: I18n.t('admin.settings_helper.feature_flags.llm_access.label'),
          description: I18n.t('admin.settings_helper.feature_flags.llm_access.description'),
          enabled: true
        ),
        hash_including(
          key: 'photo_processing',
          label: I18n.t('admin.settings_helper.feature_flags.photo_processing.label'),
          description: I18n.t('admin.settings_helper.feature_flags.photo_processing.description'),
          enabled: true
        )
      )
    end
  end

  describe '#cloud_import_provider_states_for_settings' do
    before do
      allow(ENV).to receive(:[]).and_call_original
      allow(ENV).to receive(:[]).with('GOOGLE_DRIVE_CLIENT_ID').and_return(nil)
      allow(ENV).to receive(:[]).with('GOOGLE_DRIVE_CLIENT_SECRET').and_return(nil)
      allow(ENV).to receive(:[]).with('DROPBOX_APP_KEY').and_return(nil)
      allow(ENV).to receive(:[]).with('DROPBOX_APP_SECRET').and_return(nil)
    end

    it 'builds setup guidance for unconfigured connectors' do
      google_drive_state = helper.cloud_import_provider_states_for_settings.find do |provider|
        provider.fetch(:key) == 'google_drive'
      end

      expect(google_drive_state).to include(
        label: I18n.t('resumes.cloud_import_provider_catalog.providers.google_drive.label'),
        configured: false,
        status_label: I18n.t('admin.settings_helper.cloud_import_provider_states.status.setup_required'),
        status_tone: :warning
      )
      expect(google_drive_state.fetch(:description)).to eq(I18n.t('resumes.cloud_import_provider_catalog.providers.google_drive.description'))
      expect(google_drive_state.fetch(:message)).to eq(
        I18n.t('resumes.cloud_import_provider_catalog.feedback.setup_required', provider: I18n.t('resumes.cloud_import_provider_catalog.providers.google_drive.label'), env_vars: 'GOOGLE_DRIVE_CLIENT_ID and GOOGLE_DRIVE_CLIENT_SECRET')
      )
    end

    it 'marks connectors as configured when credentials are present' do
      allow(ENV).to receive(:[]).with('DROPBOX_APP_KEY').and_return('app-key')
      allow(ENV).to receive(:[]).with('DROPBOX_APP_SECRET').and_return('app-secret')

      dropbox_state = helper.cloud_import_provider_states_for_settings.find do |provider|
        provider.fetch(:key) == 'dropbox'
      end

      expect(dropbox_state).to include(
        label: I18n.t('resumes.cloud_import_provider_catalog.providers.dropbox.label'),
        configured: true,
        status_label: I18n.t('admin.settings_helper.cloud_import_provider_states.status.configured'),
        status_tone: :success
      )
      expect(dropbox_state.fetch(:description)).to eq(I18n.t('resumes.cloud_import_provider_catalog.providers.dropbox.description'))
      expect(dropbox_state.fetch(:message)).to eq(
        I18n.t('resumes.cloud_import_provider_catalog.feedback.configured', provider: I18n.t('resumes.cloud_import_provider_catalog.providers.dropbox.label'))
      )
    end
  end

  describe '#llm_model_options_for_select' do
    it 'includes provider and inferred metadata in the option label' do
      llm_model = build_stubbed(
        :llm_model,
        name: 'Gemma 2 9B IT',
        llm_provider: build_stubbed(:llm_provider, name: 'NVIDIA Build'),
        metadata: {
          'model_type' => 'text',
          'parameter_size' => '9B',
          'family' => 'gemma'
        }
      )

      expect(helper.llm_model_options_for_select([llm_model])).to eq([
        ['Gemma 2 9B IT · NVIDIA Build · Text · 9B · gemma', llm_model.id]
      ])
    end
  end
end
