# frozen_string_literal: true

module Search
  module Bookmarks
    class Indexer < Search::Base::Indexer
      def klass
        "Bookmark"
      end

      def load_file_json(filetype)
        file = File.join(
          File.dirname(__FILE__),
          "#{filetype}.json"
        )
        JSON.parse(File.read(file))
      end

      def document(object)
        Search::Bookmarks::Document.new(object).to_hash
      end
    end
  end
end
