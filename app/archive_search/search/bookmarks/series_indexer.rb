module Search
  module Bookmarks
    class SeriesIndexer < Search::Bookmarks::BookmarkableIndexer
      def klass
        "Series"
      end

      def document_class
        SeriesDocument
      end
    end
  end
end
