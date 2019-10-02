# frozen_string_literal: true

require 'rails_helper'

describe "Works API", type: :request, work_search: :true do
  describe "#index" do
    let(:fellowship) { build(:work, title: "The Fellowship of the Ring", posted: true) }
    let(:hobbit) { build(:work, title: "The Hobbit", posted: true) }

    it "returns basic work search results" do
      fellowship.save!
      hobbit.save!
      Work.search_index.refresh
      
      params = { query: { q: "ring" } }
      get "/api/v3/works.json?" + params.to_query
      works = JSON.parse(response.body)
      titles = works.map { |work| work['title'] }

      expect(titles).to include("The Fellowship of the Ring")
      expect(titles).not_to include("The Hobbit")
    end
  end

  describe "#create" do
    let!(:user) { create(:confirmed_user) }
    let(:auth_header) do
      { 'Authorization' => authenticate(user) }
    end

    it "creates a new work" do
      language = create(:language)

      attributes = {
        title: "A new work",
        chapters: [
          { content: "With plenty of content" }
        ],
        fandoms: "Amazing Fandom",
        ratings: "Not Rated",
        archive_warnings: "No Archive Warnings Apply",
        language_id: language.id
      }

      post "/api/v3/works.json", params: { work: attributes }, headers: auth_header
      expect(response).to have_http_status(:created)
      data = JSON.parse(response.body)
      expect(data.keys).to include("id")

      get "/api/v3/works/#{data['id']}.json"
      data = JSON.parse(response.body)
      expect(data.keys).to include("title")
      expect(data["title"]).to eq("A new work")
    end
  end
end
