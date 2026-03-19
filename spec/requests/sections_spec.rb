require 'rails_helper'

RSpec.describe "Sections", type: :request do
  describe "GET /create" do
    it "returns http success" do
      get "/sections/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/sections/update"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/sections/destroy"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /move" do
    it "returns http success" do
      get "/sections/move"
      expect(response).to have_http_status(:success)
    end
  end

end
