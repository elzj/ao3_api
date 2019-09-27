# frozen_string_literal: true

module Search
  module Shared
    # Basic search clauses for elasticsearch queries
    module SearchTerms
      def term_filter(field, value)
        { term: { field => value } }
      end

      def terms_filter(field, value)
        { terms: { field => value } }
      end

      def range_filter(field, min: nil, max: nil)
        value = {}
        value[:gte] = min if min.present?
        value[:lte] = max if max.present?
        { range: { field => value } }
      end

      def exists_filter(field)
        { exists: { field: field } }
      end

      def query_string_query(fields, value, opts = {})
        operator = opts[:operator] || "and"
        {
          query_string: {
            query: value,
            fields: fields,
            default_operator: operator
          }
        }
      end

      def simple_query_string_query(fields, value, opts = {})
        operator = opts[:operator] || "and"
        {
          simple_query_string: {
            query: value,
            fields: fields,
            default_operator: operator
          }
        }
      end

      def match_query(field, value, opts = {})
        operator = opts[:operator] || "and"
        {
          match: {
            field => {
              query: value,
              operator: operator
            }.merge(opts)
          }
        }
      end

      def multi_match_query(fields, value)
        {
          multi_match: {
            query: value,
            fields: fields
          }
        }
      end

      def terms_aggregation(name, field)
        { name => { terms: { field: field } } }
      end
    end
  end
end
