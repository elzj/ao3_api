module Search
  module Bookmarks
    class SeriesIndexer < Search::Bookmarks::BookmarkableIndexer
      def klass
        "Series"
      end

      def document(object)
        SeriesDocument.new(object).to_hash
      end
    end
  end
end
