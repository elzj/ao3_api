module Search
  module Bookmarks
    class ExternalWorkIndexer < Search::Bookmarks::BookmarkableIndexer
      def klass
        "ExternalWork"
      end

      def document(object)
        ExternalWorkDocument.new(object).to_hash
      end
    end
  end
end
