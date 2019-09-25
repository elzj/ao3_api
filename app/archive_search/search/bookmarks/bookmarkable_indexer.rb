module Search
  module Bookmarks
    class BookmarkableIndexer < Search::Base::Indexer
      def index_name
        "#{ArchiveConfig.ELASTICSEARCH_PREFIX}_#{Rails.env}_bookmarks"
      end

      def document_type
        'bookmark'
      end

      def self.mapping
        Search::Bookmarks::Indexer.mapping
      end

      # When we fail, we don't want to just keep adding the -klass suffix.
      def find_elasticsearch_ids(ids)
        ids.map(&:to_i)
      end

      def routing_info(id)
        {
          '_index' => index_name,
          '_type' => document_type,
          '_id' => document_id(id)
        }
      end

      def document_id(id)
        "#{id}-#{klass.underscore}"
      end
    end
  end
end
