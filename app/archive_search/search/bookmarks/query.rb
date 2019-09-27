# frozen_string_literal: true

module Search
  module Bookmarks
    class Query < Search::Base::Query
      def klass
        'Bookmark'
      end

      def indexer_class
        Indexer
      end

      def filters
        [].compact
      end

      def musts
        [].compact
      end
    end
  end
end
