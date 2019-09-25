# frozen_string_literal: true

module Search
  module Tags
    class Form < Search::Base::Form
      ATTRIBUTES = %i(query name tag_type canonical).freeze

      ATTRIBUTES.each do |filterable|
        define_method(filterable) { options[filterable] }
      end

      def query
        Query.new(options)
      end

      def process_options
        super
        standardize_options
      end

      # Clean up boolean options and escape text query
      def standardize_options
        [:canonical, :unwrangleable, :has_posted_works].each do |term|
          next unless options[term].present?
          options[term] = Search::Sanitizer.bool_value(options[term])
        end
        if options[:name].present?
          options[:name] = Search::Sanitizer.sanitize_string(options[:name])
        end
      end
    end
  end
end
