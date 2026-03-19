class ApplicationController < ActionController::Base
  include Authentication
  include Pundit::Authorization
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user, :feature_enabled?

  rescue_from Pundit::NotAuthorizedError, with: :handle_not_authorized

  private
    def current_user
      Current.user
    end

    def feature_enabled?(key)
      PlatformSetting.current.feature_enabled?(key)
    end

    def handle_not_authorized
      redirect_to authenticated? ? resumes_path : root_path, alert: "You are not authorized to perform that action."
    end
end
