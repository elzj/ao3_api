# frozen_string_literal: true

module Search
  module Bookmarks
    class ParentIndexer
      def self.reindex(record)
        new(record).reindex
      end

      attr_reader :parent

      def initialize(parent)
        @parent = parent
      end

      def reindex
        if parent.destroyed?
          client.delete(
            index: index_name,
            id: document_id
          )
        else
          client.index(
            index: index_name,
            id: document_id,
            body: document
          )
        end
      end

      def document_id
        "#{parent.id}-#{parent.class.to_s.underscore}"
      end

      def document
        klass = case parent
                when Work
                  Search::Bookmarks::WorkDocument
                when Series
                  Search::Bookmarks::SeriesDocument
                when ExternalWork
                  Search::Bookmarks::ExternalWorkDocument
                end
        klass.new(parent).as_json
      end

      def client
        @client ||= Search::Client.new_client
      end

      def index_name
        Bookmark.search_index.name
      end
    end
  end
end
