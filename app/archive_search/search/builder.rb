# frozen_string_literal: true

module Search
  class Builder
    attr_reader :query, :options

    def initialize
      @query = {
        must: [],
        must_not: [],
        should: [],
        filter: []
      }
      @options = {
        aggs: {}
      }
    end

    def add_term_filter(key, value)
      add_filter(term_filter(key, value)) unless value.nil?
      self
    end

    def add_terms_filter(key, value)
      add_filter(terms_filter(key, value)) unless value.nil?
      self
    end

    def add_filter(filter)
      query[:filter] << filter
      self
    end

    def add_match_filter(key, value, options = {})
      add_must(
        match_filter(key, value, options)
      )
    end

    def add_match_exclusion(key, value, options = {})
      add_must_not(
        match_filter(key, value, options)
      )
    end

    def add_must(conditions)
      query[:must] << conditions
      self
    end

    def add_must_not(conditions)
      query[:must_not] << conditions
      self
    end

    def add_should(conditions)
      query[:should] << conditions
      self
    end

    def add_terms_aggregation(agg_name, field_name)
      options[:aggs][agg_name] = {
        terms: { field: field_name }
      }
    end

    def body
      options.merge(
        query: filtered_query
      )
    end

    def filtered_query
      processed = query.reject { |_, value| value.blank? }
      processed[:minimum_should_match] = 1 if processed[:should].present?
      { bool: processed }
    end

    ### PAGINATION ###

    # Add pagination to our options and make sure we're not requestiong
    # an out-of-bounds page number. Example: if the limit is 3 results,
    # and we're displaying 2 per page, disallow pages beyond page 2.
    def set_pagination(page:, per_page: ArchiveConfig.items_per_page)
      page ||= 1
      last_page = (ArchiveConfig.search[:max_results] / per_page.to_f).ceil
      page = [page, last_page].min
      pagination_offset = (page * per_page) - per_page

      options.merge!(
        size: per_page,
        from: pagination_offset
      )
    end

    def set_sorting(field, direction)
      sort = { field => { order: direction } }

      # We need an extra indicator when we're sorting by a date field
      if field.to_s =~ /date|_at/
        sort[:unmapped_type] = "date"
      end

      options.merge!(sort: sort)
    end

    ### COMMON FILTERS ###

    def term_filter(field, value)
      { term: { field => value } }
    end

    def terms_filter(field, value)
      { terms: { field => value } }
    end

    def match_filter(field, value, opts = {})
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
  end
end
