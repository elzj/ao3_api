module Search
  module Bookmarks
    class BookmarkableIndexer < Search::Base::Indexer
      def document_id(id)
        "#{id}-#{klass.underscore}"
      end
    end
  end
end
