require 'rails_helper'

RSpec.describe "Admin::JobLogs", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/admin/job_logs/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/admin/job_logs/show"
      expect(response).to have_http_status(:success)
    end
  end

end
