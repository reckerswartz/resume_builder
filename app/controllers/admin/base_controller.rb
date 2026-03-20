class Admin::BaseController < ApplicationController
  before_action :authorize_admin!

  private
    def authorize_admin!
      authorize :admin, :access?
    end

    def table_direction(default: "asc")
      %w[ asc desc ].include?(params[:direction]) ? params[:direction] : default
    end

    def table_total_pages(total_count:, per_page:)
      [ (total_count.to_f / per_page).ceil, 1 ].max
    end

    def table_current_page(total_pages:)
      requested_page = params[:page].to_i
      requested_page = 1 if requested_page < 1

      [ requested_page, total_pages ].min
    end
end
