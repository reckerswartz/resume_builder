require 'rails_helper'

RSpec.describe "Admin::Templates", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/admin/templates/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/admin/templates/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/admin/templates/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/admin/templates/edit"
      expect(response).to have_http_status(:success)
    end
  end

end
