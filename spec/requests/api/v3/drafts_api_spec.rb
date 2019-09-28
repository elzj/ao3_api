# frozen_string_literal: true

require 'rails_helper'

describe "Drafts API", type: :request do
  let!(:user) { create(:user) }

  describe "#index" do
    let!(:draft) { create(:draft, user_id: user.id) }

    it "returns an array of drafts" do
      get "/api/v3/drafts.json"
      drafts = JSON.parse(response.body)
      expect(drafts.length).to eq(1)
      expect(drafts.first["title"]).to eq(draft.title)
    end

    it "returns only the drafts for the current user"
  end

  describe "#show" do
    let!(:draft) { create(:draft, user_id: user.id) }

    it "returns an array of drafts" do
      get "/api/v3/drafts/#{draft.id}.json"
      data = JSON.parse(response.body)
      expect(data.keys).to include("title")
      expect(data["title"]).to eq(draft.title)
    end

    it "returns only a draft for the current user"
  end

  describe "#create" do
    it "creates a draft" do
      attributes = {
        title: "The Hobbit",
        archive_warnings: "Major Character Death",
        characters: "Bilbo, Gandalf, Thorin",
        freeforms: "fantasy, dragons"
      }
      post "/api/v3/drafts.json", params: { draft: attributes }
      expect(response).to have_http_status(:created)
      data = JSON.parse(response.body)
      expect(data.keys).to include("id")

      get "/api/v3/drafts/#{data['id']}.json"
      data = JSON.parse(response.body)
      expect(data.keys).to include("title")
      expect(data["title"]).to eq("The Hobbit")
      expect(data["freeforms"]).to eq("fantasy, dragons")
    end
  end
end
