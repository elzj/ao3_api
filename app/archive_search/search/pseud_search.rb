# frozen_string_literal: true

module Search
  # The main interface between the model and the custom search code
  class PseudSearch
    include ActiveModel::Model
    include Search::Pseuds::Settings
    include Search::Shared::SearchMethods

    ATTRIBUTES = %w(
      q name fandom
      collection_ids tag_ids
      sort_column sort_direction
      current_user
    ).freeze

    attr_accessor(*ATTRIBUTES)

    # The JSON document to be indexed
    def self.document(pseud)
      Search::Pseuds::Document.new(pseud).as_json
    end

    def self.mappings
      MAPPINGS
    end

    def self.settings
      SETTINGS
    end

    # Generate an elasticsearch query
    def search_body
      process_input unless processed?
      Search::Pseuds::Query.new(attributes).to_hash
    end

    # Pass our query to the searchkick search method
    def search_results(load: true)
      Pseud.search(body: search_body, load: load)
    end

    def process_input
      find_fandoms

      @processed = true
    end

    # Given one or more tag names, separate by comma and then
    # try to find the given tags
    def find_fandoms
      return unless fandom.present?
      names = fandom.split(',').map(&:squish)
      self.tag_ids ||= []
      self.tag_ids += Tag.where(name: names).pluck(:id)
      self.fandom = nil
    end

    def processed?
      @processed
    end
  end
end
