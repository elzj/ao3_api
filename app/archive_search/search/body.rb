# frozen_string_literal: true

module Search
  # Given a bunch of search data, turn it into a properly formed
  # Elasticsearch search body
  class Body
    DEFAULT_PAGE_SIZE = ArchiveConfig.items_per_page

    attr_reader :bool, :current_page, :size, :sorting

    # Begin with an empty bool context
    def initialize
      @bool = Bool.new
      @aggregations = {}
    end

    def all
      bool.filter(:match_all)
      self
    end

    # Add a condition to the bool context
    # These are chainable and cumulative
    def filter(query_type, options = {})
      bool.filter(query_type, options)
      self
    end

    def must(query_type, options = {})
      bool.must(query_type, options)
      self
    end

    def must_not(query_type, options = {})
      bool.must_not(query_type, options)
      self
    end

    def should(query_type, options = {})
      bool.should(query_type, options)
      self
    end

    def aggregate(label, field)
      @aggregations[label] = {
        terms: { field: field }
      }
      self
    end

    # Set a page value for the query
    # Needs a size to get the offset, so use a default if none is provided
    def page(num)
      @current_page = num.to_i
      @size ||= DEFAULT_PAGE_SIZE
      self
    end

    # Set a page size value for the query
    # Defaults to page 1 if no page value is set
    def per_page(limit)
      @size = limit.to_i
      @current_page ||= 1
      self
    end

    # Set the sort field and direction
    def sort(field, direction = 'desc')
      @sorting = { field => direction }
      self
    end

    # Calculates the offset for this query
    # Eg, if page == 1 and size == 20, it should be 0
    # if page == 3 and size == 25, it should be 50
    def offset
      (current_page * size) - size
    end

    # Returns a query hash for use in elasticsearch searches
    def to_hash
      data = size ? { size: size, from: offset } : {}
      data[:sort] = sorting if sorting
      data[:query] = bool.to_hash unless bool.to_hash[:bool].empty?
      data[:aggs] = @aggregations unless @aggregations.empty?
      data
    end
  end
end
