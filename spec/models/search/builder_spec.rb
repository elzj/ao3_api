# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Search::Builder, type: :model do
  let(:builder) { Search::Builder.new }

  describe '#add_term_filter' do
    it 'adds a term filter to the query' do
      builder.add_term_filter(:posted, true)
      expect(builder.query).to have_key(:filter)
      expect(builder.query[:filter]).to include(term: { posted: true })
    end

    it 'does not override existing data' do
      builder.add_term_filter(:posted, true)
      builder.add_term_filter(:type, 'Video')

      filters = builder.query[:filter]
      expect(filters.length).to eq(2)
      expect(filters).to include(term: { type: 'Video' })
    end

    it 'screens out nil values' do
      builder.add_term_filter(:revealed, nil)
      filters = builder.query[:filter]
      expect(filters.length).to eq(0)
    end
  end

  describe '#add_terms_filter' do
    it 'adds a terms filter to the query' do
      builder.add_terms_filter(:tag_ids, [3, 2, 1])

      filters = builder.query[:filter]
      expect(filters).to include(terms: { tag_ids: [3, 2, 1] })
    end

    it 'does not override existing data' do
      builder.add_terms_filter(:fandom_ids, [16, 25])
      builder.add_terms_filter(:user_ids, [666])

      filters = builder.query[:filter]
      expect(filters.length).to eq(2)
      expect(filters).to include(terms: { user_ids: [666] })
    end

    it 'screens out nil values' do
      builder.add_terms_filter(:user_ids, nil)
      filters = builder.query[:filter]
      expect(filters.length).to eq(0)
    end
  end

  describe '#add_filter' do
    it 'adds a filter to the query' do
      builder.add_filter(foo: { bar: 'baz' })
      filters = builder.query[:filter]
      expect(filters).to include(foo: { bar: 'baz' })
    end
  end

  describe '#add_must' do
    it 'adds a query to the must list' do
      query = { query_string: { query: "Gandalf" } }
      builder.add_must(query)
      musts = builder.query[:must]
      expect(musts.length).to eq(1)
      expect(musts).to include(query)
    end
  end

  describe '#add_must_not' do
    it 'adds a query to the must not list' do
      query = { query_string: { query: "Sauron" } }
      builder.add_must_not(query)
      must_nots = builder.query[:must_not]
      expect(must_nots.length).to eq(1)
      expect(must_nots).to include(query)
    end
  end

  describe '#add_should' do
    it 'adds a query to the should list' do
      query = { query_string: { query: "Frodo" } }
      builder.add_should(query)
      shoulds = builder.query[:should]
      expect(shoulds.length).to eq(1)
      expect(shoulds).to include(query)
    end
  end

  describe '#add_terms_aggregation' do
    it 'adds a terms aggregation' do
      builder.add_terms_aggregation(:fandoms, "fandoms.id")
      aggregation = {
        fandoms: {
          terms: { field: "fandoms.id" }
        }
      }
      expect(builder.options[:aggs]).to include(aggregation)
    end
  end

  describe '#filtered_query' do
    it 'returns a bool hash' do
      builder.add_term_filter(:posted, true)
      builder.add_terms_filter(:user_ids, [9])
      builder.add_must(query_string: { query: "Gandalf" })
      builder.add_must_not(query_string: { query: "Dumbledore" })
      builder.add_should(query_string: { query: "Frodo" })
      builder.add_should(query_string: { query: "Bilbo" })

      desired_result = {
        bool: {
          filter: [
            { term: { posted: true } },
            { terms: { user_ids: [9] } }
          ],
          must: [
            { query_string: { query: "Gandalf" } }
          ],
          must_not: [
            { query_string: { query: "Dumbledore" } }
          ],
          should: [
            { query_string: { query: "Frodo" } },
            { query_string: { query: "Bilbo" } }
          ],
          minimum_should_match: 1
        }
      }
      expect(builder.filtered_query).to match(desired_result)
    end

    it 'removes empty fields' do
      builder.add_term_filter(:posted, true)
      expect(builder.filtered_query[:bool]).to have_key(:filter)
      expect(builder.filtered_query[:bool]).not_to have_key(:must)
      expect(builder.filtered_query[:bool]).not_to have_key(:must_not)
      expect(builder.filtered_query[:bool]).not_to have_key(:should)
    end

    it 'only adds minimum_should_match value when shoulds are present' do
      builder.add_must(query_string: { query: "Gandalf" })
      expect(builder.filtered_query[:bool]).not_to have_key(:minimum_should_match)
    end
  end

  describe '#body' do
    it 'includes all added data' do
      builder.add_term_filter(:posted, true)
      builder.set_pagination(per_page: 25, page: 3)
      builder.set_sorting(:title, :asc)
      builder.add_terms_aggregation(:tags, :tag_ids)

      desired_result = {
        query: {
          bool: {
            filter: [
              { term: { posted: true } }
            ]
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

    describe '#set_sorting' do
      it 'adds a field when sorting by date' do
        builder.set_sorting(:created_at, :desc)
        desired_result = {
          created_at: { order: :desc },
          unmapped_type: 'date'
        }
        expect(builder.options[:sort]).to eq(desired_result)
      end
    end

    describe '#set_pagination' do
      # will change if max_results changes from 100,000
      it 'stops you from requesting nonexistent pages' do
        builder.set_pagination(per_page: 100, page: 1010)
        # would normally return 100_900 which is over the limit
        expect(builder.options[:from]).to eq(99_900)
      end
    end
  end
end
