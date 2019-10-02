module Search
  module Shared
    module SearchMethods
      def attributes
        self.as_json.reject do |_, value|
          value.nil? || (value.respond_to?(:empty?) && value.empty?)
        end
      end

      def processed?
        @processed
      end

      # For a given field, get the current value, then run it
      # through the appropriate sanitize method, then reset the field
      def sanitize_field(field, sanitize_method)
        value = send(field)
        return if value.nil?
        sanitized = Search::Sanitizer.send(sanitize_method, value)
        send("#{field}=", sanitized)
      end

      def set_sorting
        unless legal_sort_values.include?(sort_column)
          self.sort_column = default_sort_column
        end
        return if sort_direction && %w(asc desc).include?(sort_direction.downcase)
        self.sort_direction = default_sort_direction
      end

      def legal_sort_values
        %w(_score)
      end

      def default_sort_column
        '_score'
      end

      def default_sort_direction
        'desc'
      end
    end
  end
end
