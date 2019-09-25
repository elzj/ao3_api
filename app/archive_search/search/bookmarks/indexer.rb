# frozen_string_literal: true

module Search
  module Bookmarks
    # Indexer for bookmarks
    class Indexer < Search::Base::Indexer
      def klass
        "Bookmark"
      end

      def index_class
        Index
      end

      def document_class
        Document
      end
    end
  end
end
