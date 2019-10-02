# frozen_string_literal: true

require 'rails_helper'

describe Search::Body, type: :model do
  describe "#filter" do
    it "adds filters to a central query" do
      body = Search::Body.new
      body.filter(:term, posted: true)

      desired_result = {
        query: {
          bool: {
            filter: [
              { term:  { posted: true } }
            ]            
          }
        }
      }
      expect(body.to_hash).to match(desired_result)
    end
  end

  describe "#must" do
    it "adds requirements to a central boolean query" do
      body = Search::Body.new
      body.must(:match, title: "foo")

      desired_result = {
        query: {
          bool: {
            must: [{ match: { title: "foo" } }]
          }
        }
      }
      expect(body.to_hash).to match(desired_result)
    end
  end

  describe "#must_not" do
    it "adds exclusion to a central boolean query" do
      body = Search::Body.new
      body.must_not(:match, title: "foo")

      desired_result = {
        query: {
          bool: {
            must_not: [{ match: { title: "foo" } }]
          }
        }
      }
      expect(body.to_hash).to match(desired_result)
    end
  end

  describe "#should" do
    it "adds an optional condition to a central boolean query" do
      body = Search::Body.new
      body.should(:match, name: "Frodo")
      body.should(:match, name: "Bilbo")

      desired_result = {
        query: {
          bool: {
            should: [
              { match: { name: "Frodo" } },
              { match: { name: "Bilbo" } }
            ],
            minimum_should_match: 1
          }
        }
      }
      expect(body.to_hash).to match(desired_result)
    end
  end

  describe "#to_hash" do
    it "returns a search body with all options" do
      body = Search::Body.new
      body.filter(:term, posted: true)
          .must(:match, title: "rings")
          .must_not(:terms, tag_ids: [3, 4])
          .should(:match, name: "Frodo")
          .should(:match, name: "Bilbo")
          .page(2)
          .per_page(25)
          .sort(:revised_at, :desc)

      desired_result = {
        query: {
          bool: {
            filter: [
              { term: { posted: true } }
            ],
            must: [
              { match: { title: "rings" } }
            ],
            must_not: [
              { terms: { tag_ids: [3, 4] } }
            ],
            should: [
              { match: { name: "Frodo" } },
              { match: { name: "Bilbo" } }
            ],
            minimum_should_match: 1
          }
        },
        from: 25,
        size: 25,
        sort: { revised_at: :desc }
      }
      expect(body.to_hash).to match(desired_result)
    end
  end
end
