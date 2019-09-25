# frozen_string_literal: true

module Search
  module Bookmarks
    class Form < Search::Base::Form
      def query_class
        Query
      end
    end
  end
end
