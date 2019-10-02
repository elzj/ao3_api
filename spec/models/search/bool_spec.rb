# frozen_string_literal: true

require 'rails_helper'

describe Search::Bool, type: :model do
  describe "#filter" do
    it "adds filters to a central query" do
      bool = Search::Bool.new
      bool.filter(:term, posted: true)
      bool.filter(:range, word_count: { lte: 1000 })

      desired_result = {
        filter: [
          { term:  { posted: true } },
          { range: { word_count: { lte: 1000 } } }
        ]
      }
      expect(bool.to_hash[:bool]).to match(desired_result)
    end
  end

  describe "#must" do
    it "adds requirements to a central boolean query" do
      bool = Search::Bool.new
      bool.must(:match, title: "foo")

      desired_result = {
        must: [{ match: { title: "foo" } }]
      }
      expect(bool.to_hash[:bool]).to match(desired_result)
    end
  end

  describe "#must_not" do
    it "adds exclusion to a central boolean query" do
      bool = Search::Bool.new
      bool.must_not(:match, title: "foo")

      desired_result = {
        must_not: [{ match: { title: "foo" } }]
      }
      expect(bool.to_hash[:bool]).to match(desired_result)
    end
  end

  describe "#should" do
    it "adds an optional condition to a central boolean query" do
      bool = Search::Bool.new
      bool.should(:match, name: "Frodo")
      bool.should(:match, name: "Bilbo")

      desired_result = {
        should: [
          { match: { name: "Frodo" } },
          { match: { name: "Bilbo" } }
        ],
        minimum_should_match: 1
      }
      expect(bool.to_hash[:bool]).to match(desired_result)
    end
  end

  describe "#to_hash" do
    it "returns a boolean query with all options" do
      bool = Search::Bool.new
      bool.filter(:term, posted: true)
      bool.must(:match, title: "rings")
      bool.must_not(:terms, tag_ids: [3, 4])
      bool.should(:match, name: "Frodo")
      bool.should(:match, name: "Bilbo")

      desired_result = {
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
      }
      expect(bool.to_hash).to match(desired_result)
    end
  end
end
