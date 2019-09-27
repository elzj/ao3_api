# frozen_string_literal: true

require 'rails_helper'

describe "Tags API", type: :request, tag_search: :true do
  describe "#index" do
    before(:each) do
      Search::Tags::Index.new.prepare_for_testing
      fluff = Freeform.create(name: "fluff", canonical: false)
      kirk = Character.create(name: "James T. Kirk", canonical: true)
      index_and_refresh(Search::Tags::Indexer, [fluff, kirk])
    end

    it "returns accurate tag search results" do
      params = { query: { name: "fluff", canonical: false, tag_type: "Freeform" } }
      get "/api/v3/tags.json?" + params.to_query
      names = JSON.parse(response.body).map { |tag| tag['name'] }
      expect(names).to include("fluff")
    end

    it "searches by canonical" do
      params = { query: { canonical: true } }
      get "/api/v3/tags.json?" + params.to_query
      names = JSON.parse(response.body).map { |tag| tag['name'] }
      expect(names).to include("James T. Kirk")
      expect(names).not_to include("fluff")
    end

    it "searches by type" do
      params = { query: { tag_type: "Freeform" } }
      get "/api/v3/tags.json?" + params.to_query
      names = JSON.parse(response.body).map { |tag| tag['name'] }
      expect(names).to include("fluff")
      expect(names).not_to include("James T. Kirk")
    end

    it "searches by name" do
      params = { query: { name: "james t. kirk" } }
      get "/api/v3/tags.json?" + params.to_query
      names = JSON.parse(response.body).map { |tag| tag['name'] }
      expect(names).to include("James T. Kirk")
      expect(names).not_to include("fluff")
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
