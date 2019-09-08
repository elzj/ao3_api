class QueryBuilder
  attr_reader :query

  def initialize
    @query = {
      must: [],
      must_not: [],
      should: [],
      filter: []
    }
  end

  def add_term_filter(key, value)
    add_filter(term: { key => value}) if value.present?
    self
  end

  def add_terms_filter(key, value)
    add_filter(terms: { key => value}) if value.present?
    self
  end

  def add_filter(filter)
    query[:filter] << filter
    self
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

  def query_body
    {
      query: filtered_query,
      # size: per_page,
      # from: pagination_offset,
      # sort: sort
    }
  end

  def filtered_query
    processed = query.reject { |_, value| value.blank? }
    processed[:minimum_should_match] = 1 if processed[:should].present?
    { bool: processed }
  end
end
