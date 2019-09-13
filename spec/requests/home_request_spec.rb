require 'rails_helper'

describe "Home", type: :request do
  describe "#index" do
    it "does not error" do
      get "/"
      expect(response).to have_http_status(:success)
    end
  end
end
