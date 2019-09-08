require 'rails_helper'

describe "Tags API", type: :request do
  describe "#index" do
    before(:all) do
      TagIndexer.new.prepare_for_testing
    end
    before(:each) do
      tag = create(:freeform, name: "fluff", canonical: false)
      index_and_refresh(TagIndexer, tag.reload)
    end

    it "returns accurate tag search results" do
      params = { query: { name: "fluff", canonical: false, tag_type: "Freeform" } }
      get "/api/v3/tags.json?" + params.to_query
      tags = JSON.parse(response.body)
      expect(tags.any?{|tag| tag['name'] == "fluff"}).to be_truthy
    end

    it "searches by canonical" do
      params = { query: { name: "fluff", canonical: true, tag_type: "Freeform" } }
      get "/api/v3/tags.json?" + params.to_query
      tags = JSON.parse(response.body)
      expect(tags.any?{|tag| tag['name'] == "fluff"}).to be_falsey
    end

    it "searches by type" do
      params = { query: { name: "fluff", canonical: false, tag_type: "Fandom" } }
      get "/api/v3/tags.json?" + params.to_query
      tags = JSON.parse(response.body)
      expect(tags.any?{|tag| tag['name'] == "fluff"}).to be_falsey
    end

    it "searches by name" do
      params = { query: { name: "angst" } }
      get "/api/v3/tags.json?" + params.to_query
      tags = JSON.parse(response.body)
      expect(tags.any?{|tag| tag['name'] == "fluff"}).to be_falsey
    end
  end

  describe "#show" do
    it "returns tag data" do
      tag = create(:freeform, name: "fluff")
      get "/api/v3/tags/#{tag.id}.json"
      expect(response).to have_http_status(:success)
      data = JSON.parse(response.body).with_indifferent_access
      expect(data[:name]).to eq("fluff")
    end
  end
end