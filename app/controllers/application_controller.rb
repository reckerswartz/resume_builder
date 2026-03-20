class ApplicationController < ActionController::Base
  include Authentication
  include Pundit::Authorization
  # Only allow modern browsers supporting webp images, web push, badges, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the asset files will invalidate the etag for HTML responses
  stale_when_assets_change if respond_to?(:stale_when_assets_change)

  helper_method :current_user, :feature_enabled?, :llm_role_enabled?
  before_action :mark_request_started_at

  rescue_from StandardError, with: :handle_internal_error
  rescue_from Pundit::NotAuthorizedError, with: :handle_not_authorized

  private
    def current_user
      Current.user
    end

    def feature_enabled?(key)
      PlatformSetting.current.feature_enabled?(key)
    end

    def llm_role_enabled?(role)
      @llm_role_enabled ||= {}
      @llm_role_enabled[role.to_s] ||= feature_enabled?("llm_access") && LlmModelAssignment.available_for?(role)
    end

    def mark_request_started_at
      @request_started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    end

    def handle_internal_error(error)
      Errors::Tracker.capture(
        error: error,
        source: :request,
        occurred_at: Time.current,
        duration_ms: request_duration_ms,
        context: request_error_context
      )

      raise error
    end

    def request_duration_ms
      return if @request_started_at.blank?

      ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - @request_started_at) * 1000).round
    end

    def request_error_context
      {
        controller: controller_path,
        action: action_name,
        method: request.request_method,
        path: request.fullpath,
        request_id: request.request_id,
        format: request.format&.to_s,
        params: request.filtered_parameters.except("controller", "action"),
        user_id: current_user&.id,
        session_id: Current.session&.id,
        ip_address: request.remote_ip,
        user_agent: request.user_agent
      }
    end

    def handle_not_authorized
      redirect_to authenticated? ? resumes_path : root_path, alert: "You are not authorized to perform that action."
    end
end
