# frozen_string_literal: true

module Search
  module Base
    # Search form classes provide an interface for views/controllers
    # and also handle the clean up and transformation of user input
    class Form
      include ActiveModel::Model

      ATTRIBUTES = %i(query_string).freeze

      attr_accessor(*ATTRIBUTES)

      def attributes
        self.as_json
      end

      def query_class
        Query
      end

      def query
        process_data unless processed?
        # Don't use 'blank' because we don't actually want
        # to remove false values
        options = attributes.reject do |_, value|
          value.nil? || (value.respond_to?(:empty?) && value.empty?)
        end
        query_class.new(options)
      end

      # Return an array of search results
      def search_results
        query.search_results
      end

      # Given a hash of options, turn it into clean data
      # that we can pass to our query
      def process_data
        # all the sanitizing and data munging
        sanitize_strings
        sanitize_numbers
        sanitize_dates
        sanitize_booleans

        @processed = true
      end

      def sanitize_strings
        string_fields.each do |field|
          sanitize_field(field, :sanitize_string)
        end
      end

      def sanitize_numbers
        number_fields.each do |field|
          sanitize_field(field, :sanitize_integer)
        end
      end

      def sanitize_dates
        date_fields.each do |field|
          sanitize_field(field, :sanitize_date)
        end
      end

      def sanitize_booleans
        boolean_fields.each do |field|
          sanitize_field(field, :bool_value)
        end
      end

      # For a given field, get the current value, then run it
      # through the appropriate sanitize method, then reset the field
      def sanitize_field(field, sanitize_method)
        value = send(field)
        return if value.nil?
        sanitized = Search::Sanitizer.send(sanitize_method, value)
        send("#{field}=", sanitized)
      end

      # Set these values in subclasses to run the sanitizer
      # methods on the fields
      def string_fields
        []
      end

      def number_fields
        []
      end

      def date_fields
        []
      end

      def boolean_fields
        []
      end

      def processed?
        @processed
      end

      def persisted?
        false
      end
    end
  end
end
