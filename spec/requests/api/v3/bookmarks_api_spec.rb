# frozen_string_literal: true

require 'rails_helper'

describe "Bookmarks API", type: :request, bookmark_search: :true do
  let(:language) { create(:language) }

  describe "#index" do
    let!(:hobbit) do
      create(
        :work,
        title: "The Hobbit",
        posted: true,
        language_id: language.id
      )
    end
    let!(:bookmark) do
      create(
        :bookmark,
        bookmarkable: hobbit,
        bookmarker_notes: "loved it",
        private: false
      )
    end

    before(:each) do
      not_found = create(
        :bookmark,
        bookmarker_notes: "hated it",
        bookmarkable: build_stubbed(:work)
      )
      Bookmark.search_index.refresh
    end

    it "returns basic search results" do
      params = { query: { q: "loved" } }
      get "/api/v3/bookmarks.json", params: params
      bookmarks = JSON.parse(response.body)

      expect(bookmarks.length).to eq(1)
      expect(bookmarks.first['notes']).to eq("loved it")
    end

    it "filters by bookmarkable tags" do
      tag = Freeform.create(name: "dragons", canonical: true)
      hobbit.taggings.create(tagger_id: tag.id)
      hobbit.filter_taggings.create(filter_id: tag.id)
      hobbit.save
      Bookmark.search_index.refresh

      params = { query: { filter_ids: [tag.id] } }
      get "/api/v3/bookmarks.json", params: params
      bookmarks = JSON.parse(response.body)

      expect(bookmarks.length).to eq(1)
      expect(bookmarks.first['notes']).to eq("loved it")
    end
  end

  describe "#create" do
    let!(:user) { create(:confirmed_user) }
    let(:auth_header) do
      { 'Authorization' => authenticate(user) }
    end

    it "creates a new bookmark" do
      work = create(:work)

      attributes = {
        bookmarkable_id: work.id,
        bookmarkable_type: "Work",
        bookmarker_notes: "my favorite work",
        private: false
      }

      post "/api/v3/bookmarks.json", params: { bookmark: attributes }, headers: auth_header
      expect(response).to have_http_status(:created)
      data = JSON.parse(response.body)
      expect(data.keys).to include("id")

      get "/api/v3/bookmarks/#{data['id']}.json"
      data = JSON.parse(response.body)
      expect(data.keys).to include("notes")
      expect(data["notes"]).to eq("my favorite work")
    end

    it "will not create a bookmark for someone else" do
      work = create(:work)

      attributes = {
        bookmarkable_id: work.id,
        bookmarkable_type: "Work",
        bookmarker_notes: "my favorite work",
        private: false,
        pseud_id: 666
      }

      post "/api/v3/bookmarks.json", params: { bookmark: attributes }, headers: auth_header
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end
end
