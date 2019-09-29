module Search
  module Bookmarks
    class WorkIndexer < Search::Bookmarks::BookmarkableIndexer
      def klass
        "Work"
      end

      def document_class
        WorkDocument
      end

      # Only index works with bookmarks
      def indexables
        Work.includes(:stat_counter).where(
          "stat_counters.bookmarks_count > 0"
        ).references(:stat_counters)
      end
    end
  end
end
