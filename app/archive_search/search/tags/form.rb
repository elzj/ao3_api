# frozen_string_literal: true

module Search
  module Tags
    # Form interface for tag searches
    class Form < Search::Base::Form
      ATTRIBUTES = %w(
        q name tag_type canonical
        current_user sort_column sort_direction
      ).freeze

      attr_accessor(*ATTRIBUTES)

      def attributes
        self.as_json(only: ATTRIBUTES)
      end

      def query_class
        Query
      end

      # Boolean fields to sanitize
      def boolean_fields
        %i(canonical)
      end

      # String fields to sanitize
      def string_fields
        %i(name)
      end
    end
  end
end
