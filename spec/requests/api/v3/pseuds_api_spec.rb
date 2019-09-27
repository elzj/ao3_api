# frozen_string_literal: true

require 'rails_helper'

describe "Pseuds API", type: :request, pseud_search: :true do
  describe "#index" do
    let(:sam) { create(:pseud, name: "sam") }
    let(:dean) { create(:pseud, name: "dean") }

    before(:each) do
      Search::Pseuds::Index.new.prepare_for_testing
      index_and_refresh(Search::Pseuds::Indexer, [sam, dean])
    end

    it "returns accurate tag search results" do
      params = { query: { name: "sam" } }
      get "/api/v3/pseuds.json?" + params.to_query
      pseuds = JSON.parse(response.body)
      names = pseuds.map { |pseud| pseud['name'] }
      expect(names).to include("sam")
      expect(names).not_to include("dean")
    end

    it "allows partial name searches" do
      params = { query: { q: "Dea*" } }
      get "/api/v3/pseuds.json?" + params.to_query
      pseuds = JSON.parse(response.body)
      names = pseuds.map { |pseud| pseud['name'] }
      expect(names).to include("dean")
      expect(names).not_to include("sam")
    end

    context "for a pseud with tagged works" do
      before do
        work = create(:work, posted: true)
        tag = Fandom.create(name: "Supernatural", canonical: true)
        work.creatorships.create(pseud_id: dean.id, approved: true)
        work.filter_taggings.create(filter_id: tag.id)
        index_and_refresh(Search::Pseuds::Indexer, [dean.reload])
      end

      it "searches by fandom" do
        params = { query: { fandom: "Supernatural" } }
        get "/api/v3/pseuds.json?" + params.to_query
        pseuds = JSON.parse(response.body)
        names = pseuds.map { |tag| tag['name'] } 
        expect(names).to include("dean")
        expect(names).not_to include("sam")
      end

      it "doesn't include restricted work fandoms when the user is logged out"
    end
  end
end
