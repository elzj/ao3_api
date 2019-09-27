# frozen_string_literal: true

module Search
  # Given a bunch of search data, turn it into a properly formed
  # Elasticsearch search body
  class Builder
    attr_reader :query, :options

    def initialize(options = {})
      @query = {}
      %i(must must_not should filter).each do |key|
        @query[key] = options[key] if options[key]
      end
      @options = {}

      if options[:aggregations].present?
        @options[:aggs] = options[:aggregations]
      end

      @options.merge!(
        pagination(options[:page], options[:per_page])
      )
      @options.merge!(
        sorting(options[:sort_column], options[:sort_direction])
      )
    end

    def body
      options.merge(
        query: bool_query
      )
    end

    private

    def bool_query
      processed = query.reject { |_, value| value.blank? }
      processed[:minimum_should_match] = 1 if processed[:should].present?
      { bool: processed }
    end

    ### PAGINATION ###

    def pagination(page, per_page)
      return {} unless page && per_page
      pagination_offset = (page * per_page) - per_page

      {
        size: per_page,
        from: pagination_offset
      }
    end

    def sorting(field, direction)
      return {} unless field && direction
      { sort: { field => { order: direction } } }
    end
  end
end
