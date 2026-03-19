require 'rails_helper'

RSpec.describe "Admin::Settings", type: :request do
  describe "GET /show" do
    it "returns http success" do
      get "/admin/settings/show"
      expect(response).to have_http_status(:success)
    end
  end

end
