module Search
  module Bookmarks
    class WorkIndexer < Search::Bookmarks::BookmarkableIndexer
      def klass
        "Work"
      end

      # Only index works with bookmarks
      def indexables
        Work.includes(:stat_counter).where(
          "stat_counters.bookmarks_count > 0"
        ).references(:stat_counters)
      end

      def document(object)
        WorkDocument.new(object).to_hash
      end
    end
  end
end
