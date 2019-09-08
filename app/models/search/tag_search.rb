# frozen_string_literal: true

class TagSearch
  attr_reader :options, :query

  def initialize(options={})
    @options = options
    @query = QueryBuilder.new
  end

  def results
    client = SearchClient.new_client
    response = client.search(index: index_name, body: processed_query)
    hits = response.dig('hits', 'hits')
    hits ? hits.map{ |hit| hit['_source'] } : []
  end

  def index_name
    SearchHelper.index_name('tags')
  end

  def processed_query
    standardize_options
    add_term_filters
    add_terms_filters
    add_wrangled_filter
    add_name_query
    
    query.query_body
  end

  def add_term_filters
    %i[tag_type canonical unwrangleable has_posted_works].each do |term|
      query.add_term_filter(term, options[term])
    end
  end

  def add_terms_filters
    %i[media_ids fandom_ids character_ids pre_fandom_ids pre_character_ids].each do |term|
      query.add_terms_filter(term, options[term])
    end
  end

  def add_wrangled_filter
    return if options[:wrangled].nil?
    query.add_filter({ exists: { field: "fandom_ids" } })
  end

  def add_name_query
    return if options[:name].blank?
    query.add_must({
      query_string: {
        query: options[:name],
        fields: ["name.exact^2", "name"],
        default_operator: "and"
      }
    })
  end

  # Clean up boolean options
  def standardize_options
    [:canonical, :unwrangleable, :has_posted_works].each do |term|
      next unless options[term].present?
      options[term] = SearchHelper.standardize_boolean(options[term])
    end
    if options[:name].present?
      options[:name] = SearchHelper.sanitize_string(options[:name])
    end
  end
end
