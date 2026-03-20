require 'rails_helper'

RSpec.describe Admin::SettingsHelper, type: :helper do
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
        label: 'Google Drive',
        configured: false,
        status_label: 'Setup required',
        status_tone: :warning
      )
      expect(google_drive_state.fetch(:message)).to include('GOOGLE_DRIVE_CLIENT_ID')
    end

    it 'marks connectors as configured when credentials are present' do
      allow(ENV).to receive(:[]).with('DROPBOX_APP_KEY').and_return('app-key')
      allow(ENV).to receive(:[]).with('DROPBOX_APP_SECRET').and_return('app-secret')

      dropbox_state = helper.cloud_import_provider_states_for_settings.find do |provider|
        provider.fetch(:key) == 'dropbox'
      end

      expect(dropbox_state).to include(
        label: 'Dropbox',
        configured: true,
        status_label: 'Configured',
        status_tone: :success
      )
      expect(dropbox_state.fetch(:message)).to include('Environment credentials are present')
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
