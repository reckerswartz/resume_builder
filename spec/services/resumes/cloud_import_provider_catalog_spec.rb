require 'rails_helper'

RSpec.describe Resumes::CloudImportProviderCatalog do
  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('GOOGLE_DRIVE_CLIENT_ID').and_return(nil)
    allow(ENV).to receive(:[]).with('GOOGLE_DRIVE_CLIENT_SECRET').and_return(nil)
    allow(ENV).to receive(:[]).with('DROPBOX_APP_KEY').and_return(nil)
    allow(ENV).to receive(:[]).with('DROPBOX_APP_SECRET').and_return(nil)
  end

  describe '.all' do
    it 'returns hydrated provider definitions with localized metadata and configuration state' do
      allow(ENV).to receive(:[]).with('DROPBOX_APP_KEY').and_return('app-key')
      allow(ENV).to receive(:[]).with('DROPBOX_APP_SECRET').and_return('app-secret')

      providers = described_class.all
      google_drive = providers.find { |provider| provider.fetch(:key) == 'google_drive' }
      dropbox = providers.find { |provider| provider.fetch(:key) == 'dropbox' }

      expect(google_drive).to include(
        key: 'google_drive',
        required_env_vars: %w[GOOGLE_DRIVE_CLIENT_ID GOOGLE_DRIVE_CLIENT_SECRET],
        label: I18n.t('resumes.cloud_import_provider_catalog.providers.google_drive.label'),
        description: I18n.t('resumes.cloud_import_provider_catalog.providers.google_drive.description'),
        configured: false
      )

      expect(dropbox).to include(
        key: 'dropbox',
        required_env_vars: %w[DROPBOX_APP_KEY DROPBOX_APP_SECRET],
        label: I18n.t('resumes.cloud_import_provider_catalog.providers.dropbox.label'),
        description: I18n.t('resumes.cloud_import_provider_catalog.providers.dropbox.description'),
        configured: true
      )
    end
  end

  describe '.fetch' do
    it 'returns a hydrated provider for a known key' do
      provider = described_class.fetch(:google_drive)

      expect(provider).to include(
        key: 'google_drive',
        label: I18n.t('resumes.cloud_import_provider_catalog.providers.google_drive.label'),
        configured: false
      )
    end

    it 'returns nil for an unknown provider key' do
      expect(described_class.fetch('unknown-provider')).to be_nil
    end
  end

  describe '.launch_feedback' do
    it 'returns the unavailable alert when the provider key is unknown' do
      expect(described_class.launch_feedback('unknown-provider')).to eq(
        level: :alert,
        message: I18n.t('resumes.cloud_import_provider_catalog.feedback.provider_unavailable')
      )
    end

    it 'returns the configured alert when all required credentials are present' do
      allow(ENV).to receive(:[]).with('DROPBOX_APP_KEY').and_return('app-key')
      allow(ENV).to receive(:[]).with('DROPBOX_APP_SECRET').and_return('app-secret')

      expect(described_class.launch_feedback('dropbox')).to eq(
        level: :alert,
        message: I18n.t(
          'resumes.cloud_import_provider_catalog.feedback.configured',
          provider: I18n.t('resumes.cloud_import_provider_catalog.providers.dropbox.label')
        )
      )
    end

    it 'returns the setup-required alert when credentials are missing' do
      expect(described_class.launch_feedback('google_drive')).to eq(
        level: :alert,
        message: I18n.t(
          'resumes.cloud_import_provider_catalog.feedback.setup_required',
          provider: I18n.t('resumes.cloud_import_provider_catalog.providers.google_drive.label'),
          env_vars: %w[GOOGLE_DRIVE_CLIENT_ID GOOGLE_DRIVE_CLIENT_SECRET].to_sentence
        )
      )
    end
  end
end
