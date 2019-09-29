module Search
  module Bookmarks
    class BookmarkableIndexer < Search::Base::Indexer
      def index_class
        Index
      end

      def document_id(id)
        "#{id}-#{klass.underscore}"
      end
    end
  end
end
