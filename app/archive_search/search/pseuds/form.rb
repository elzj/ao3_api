# frozen_string_literal: true

module Search
  module Pseuds
    class Form < Search::Base::Form
      ATTRIBUTES = %i[query name collection_ids fandom]

      ATTRIBUTES.each do |filterable|
        define_method(filterable) { options[filterable] }
      end

      def query_class
        Query
      end

      def process_options
        set_fandoms
        super
      end

      def set_fandoms
        return unless @options[:fandom].present?
        names = @options[:fandom].split(',').map(&:squish)
        @options[:fandom_ids] = Tag.where(name: names).pluck(:id)
      end
    end
  end
end
