# frozen_string_literal: true

module Search
  module Pseuds
    # Form interface for pseud searches
    class Form < Search::Base::Form
      ATTRIBUTES = %i(
        q name current_user
        collection_ids fandom tag_ids
      ).freeze
      attr_accessor(*ATTRIBUTES)

      def query_class
        Query
      end

      def process_data
        set_fandoms
        super
      end

      # Given one or more tag names, separate by comma and then
      # try to find the given tags
      def set_fandoms
        return unless fandom.present?
        names = fandom.split(',').map(&:squish)
        self.tag_ids ||= []
        self.tag_ids += Tag.where(name: names).pluck(:id)
      end
    end
  end
end
