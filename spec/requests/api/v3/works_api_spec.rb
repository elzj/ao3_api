# frozen_string_literal: true

require 'rails_helper'

describe "Works API", type: :request, work_search: :true do
  let(:indexer) { Search::Works::Indexer }

  describe "#index" do
    let(:fellowship) { build(:work, title: "The Fellowship of the Ring", posted: true) }
    let(:hobbit) { build(:work, title: "The Hobbit", posted: true) }

    before(:each) do
      Search::Works::Index.new.prepare_for_testing
    end

    it "returns basic work search results" do
      fellowship.save!
      hobbit.save!
      index_and_refresh(indexer, [fellowship, hobbit])

      params = { query: { q: "ring" } }
      get "/api/v3/works.json?" + params.to_query
      works = JSON.parse(response.body)
      titles = works.map { |work| work['title'] }

      expect(titles).to include("The Fellowship of the Ring")
      expect(titles).not_to include("The Hobbit")
    end
  end
end