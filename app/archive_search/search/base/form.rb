# frozen_string_literal: true

module Search
  module Base
    class Form
      extend ActiveModel::Naming
      include ActiveModel::Conversion
      include ActiveModel::Validations

      attr_reader :options

      def initialize(options = {})
        @options = options
        process_options
      end

      def query
        Query.new(options)
      end

      def search_results
        query.search_results
      end

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
