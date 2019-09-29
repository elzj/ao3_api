module Search
  module Bookmarks
    class ExternalWorkIndexer < Search::Bookmarks::BookmarkableIndexer
      def klass
        "ExternalWork"
      end

      def document_class
        ExternalWorkDocument
      end
    end
  end
end
