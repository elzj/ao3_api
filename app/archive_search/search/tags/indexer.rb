# frozen_string_literal: true

module Search
  module Tags
    # Indexer for the tag class
    class Indexer < Search::Base::Indexer
      def klass
        "Tag"
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
