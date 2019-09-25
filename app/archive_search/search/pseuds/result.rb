# frozen_string_literal: true

module Search
  module Pseuds
    class Result < Search::Base::Result
      # Laying some groundwork for making better use of search results
      def decorate_items(items)
        PseudDecorator.decorate_from_search(items, hits)
      end
    end
  end
end
