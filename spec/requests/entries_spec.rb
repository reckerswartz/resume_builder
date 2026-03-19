require 'rails_helper'

RSpec.describe "Entries", type: :request do
  describe "GET /create" do
    it "returns http success" do
      get "/entries/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/entries/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/entries/destroy"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /move" do
    it "returns http success" do
      get "/entries/move"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /improve" do
    it "returns http success" do
      get "/entries/improve"
      expect(response).to have_http_status(:success)
    end
  end

end
