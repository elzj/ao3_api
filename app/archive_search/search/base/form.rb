# frozen_string_literal: true

module Search
  module Base
    # Search form classes provide an interface for views/controllers
    # and also handle the clean up and transformation of user input
    class Form
      extend ActiveModel::Naming
      include ActiveModel::Conversion
      include ActiveModel::Validations

      attr_reader :options

      def initialize(options = {})
        @options = options
        process_options
      end

      def query_class
        Query
      end

      def querier
        query_class.new(options)
      end

      # Return an array of search results
      def search_results
        query_class.new(options).search_results
      end

      # Given a hash of options, turn it into clean data
      # that we can pass to our query
      def process_options
        # all the sanitizing and data munging
        options.delete_if { |_, v| v.blank? }
      end

      def persisted?
        false
      end
    end
  end
end
