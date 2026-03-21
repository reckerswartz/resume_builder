module Resumes
  class CloudImportProviderCatalog
    PROVIDERS = [
      {
        key: "google_drive",
        required_env_vars: %w[GOOGLE_DRIVE_CLIENT_ID GOOGLE_DRIVE_CLIENT_SECRET]
      },
      {
        key: "dropbox",
        required_env_vars: %w[DROPBOX_APP_KEY DROPBOX_APP_SECRET]
      }
    ].freeze

    class << self
      def all
        PROVIDERS.map { |provider| hydrate(provider) }
      end

      def fetch(key)
        provider = PROVIDERS.find { |definition| definition.fetch(:key) == key.to_s }
        provider.present? ? hydrate(provider) : nil
      end

      def launch_feedback(key)
        provider = fetch(key)
        return { level: :alert, message: I18n.t("resumes.cloud_import_provider_catalog.feedback.provider_unavailable") } if provider.blank?

        if provider.fetch(:configured)
          {
            level: :alert,
            message: I18n.t("resumes.cloud_import_provider_catalog.feedback.configured", provider: provider.fetch(:label))
          }
        else
          {
            level: :alert,
            message: I18n.t("resumes.cloud_import_provider_catalog.feedback.setup_required", provider: provider.fetch(:label), env_vars: provider.fetch(:required_env_vars).to_sentence)
          }
        end
      end

      private
        def hydrate(provider)
          provider.merge(
            label: I18n.t("resumes.cloud_import_provider_catalog.providers.#{provider.fetch(:key)}.label"),
            description: I18n.t("resumes.cloud_import_provider_catalog.providers.#{provider.fetch(:key)}.description"),
            configured: provider.fetch(:required_env_vars).all? { |env_var| ENV[env_var].present? }
          )
        end
    end
  end
end
