# frozen_string_literal: true

module Search
  # Represents the core of an elasticsearch boolean search
  class Bool
    include Elasticsearch::DSL

    attr_accessor :filters, :musts, :must_nots, :shoulds
    attr_accessor :min_should_match, :boost

    def initialize
      @filters   = []
      @musts     = []
      @must_nots = []
      @shoulds   = []
    end

    def filter(filter_type, options = {})
      klass = filter_class(filter_type)
      self.filters << klass.new(options).to_hash
      self
    end

    def must(query_type, options = {})
      klass = query_class(query_type)
      self.musts << klass.new(options).to_hash
      self
    end

    def must_not(query_type, options = {})
      klass = query_class(query_type)
      self.must_nots << klass.new(options).to_hash
      self
    end

    def should(query_type, options = {})
      klass = query_class(query_type)
      self.shoulds << klass.new(options).to_hash
      if options[:min_should_match]
        self.min_should_match = options[:min_should_match]
      else
        self.min_should_match ||= 1
      end
      self
    end

    def filter_class(query_type)
      (
        "Elasticsearch::DSL::Search::Filters::" +
          query_type.to_s.camelize
      ).constantize
    end

    def query_class(query_type)
      (
        "Elasticsearch::DSL::Search::Queries::" +
          query_type.to_s.camelize
      ).constantize
    end

    def to_hash
      bool = {
        filter:   filters,
        must:     musts,
        must_not: must_nots,
        should:   shoulds
      }.delete_if { |_, val| val.empty? }

      bool[:minimum_should_match] = min_should_match if min_should_match
      bool[:boost] = boost if boost

      { bool: bool }
    end
  end
end
