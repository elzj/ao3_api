# frozen_string_literal: true

module Search
  module Bookmarks
    class Query < Search::Base::Query
      def klass
        'Bookmark'
      end

      def indexer
        Search::Bookmarks::Indexer.new
      end

      def filters
        [].compact
      end

      def queries
        [].compact
      end
    end
  end
end
