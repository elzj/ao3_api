# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Search::Builder, type: :model do
  describe '#body' do
    let(:options) do
      {
        filter: [
          { term: { posted: true } }
        ],
        must: [
          { match: { tag: "Gandalf" } }
        ],
        must_not: [
          { match: { tag: "Dumbledore" } }
        ],
        should: [
          { match: { tag: "Frodo" } },
          { match: { tag: "Bilbo" } }
        ],
        aggregations: {
          tags: {
            terms: { field: :tag_ids }
          }
        },
        sort_column: :title,
        sort_direction: :asc,
        page: 3,
        per_page: 25
      }
    end

    it 'includes all added data' do
      builder = Search::Builder.new(options)

      desired_result = {
        query: {
          bool: {
            filter: [
              { term: { posted: true } }
            ],
            must: [
              { match: { tag: "Gandalf" } }
            ],
            must_not: [
              { match: { tag: "Dumbledore" } }
            ],
            should: [
              { match: { tag: "Frodo" } },
              { match: { tag: "Bilbo" } }
            ],
            minimum_should_match: 1
          }
        },
        size: 25,
        from: 50,
        sort: { title: { order: :asc } },
        aggs: {
          tags: {
            terms: { field: :tag_ids }
          }
        }
      }
      expect(builder.body).to match(desired_result)
    end

    it "does not include empty fields" do
      builder = Search::Builder.new(filter: options[:filter])

      desired_result = {
        query: {
          bool: {
            filter: [
              { term: { posted: true } }
            ]
          }
        }
      }
      expect(builder.body).to match(desired_result)
    end
  end
end
