# frozen_string_literal: true

module Search
  module Pseuds
    # Indexer for the pseuds class
    class Indexer < Search::Base::Indexer
      def klass
        "Pseud"
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
