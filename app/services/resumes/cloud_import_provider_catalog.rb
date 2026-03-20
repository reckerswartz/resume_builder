module Resumes
  class CloudImportProviderCatalog
    PROVIDERS = [
      {
        key: "google_drive",
        label: "Google Drive",
        description: "Browse a Drive file after provider auth is wired and keep the imported file attached to the draft.",
        required_env_vars: %w[GOOGLE_DRIVE_CLIENT_ID GOOGLE_DRIVE_CLIENT_SECRET]
      },
      {
        key: "dropbox",
        label: "Dropbox",
        description: "Choose a Dropbox file after provider auth is wired and keep the imported file attached to the draft.",
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
        return { level: :alert, message: "Cloud import provider is not available." } if provider.blank?

        if provider.fetch(:configured)
          {
            level: :alert,
            message: "#{provider.fetch(:label)} import is not connected yet. Provider auth handoff is the next rollout step."
          }
        else
          {
            level: :alert,
            message: "#{provider.fetch(:label)} import is not configured. Add #{provider.fetch(:required_env_vars).to_sentence} to enable this connector."
          }
        end
      end

      private
        def hydrate(provider)
          provider.merge(
            configured: provider.fetch(:required_env_vars).all? { |env_var| ENV[env_var].present? }
          )
        end
    end
  end
end
