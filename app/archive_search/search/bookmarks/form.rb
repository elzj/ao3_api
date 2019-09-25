# frozen_string_literal: true

module Search
  module Bookmarks
    class Form < Search::Base::Form
      def query
        Query.new(options)
      end
    end
  end
end
