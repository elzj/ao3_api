# frozen_string_literal: true

module Search
  module Bookmarks
    # Handles the setup and teardown of an individual index
    class Index < Search::Base::Index
      def self.klass
        "Bookmark"
      end
    end
  end
end
