# frozen_string_literal: true

module Search
  module Base
    # A search result collection parsed from the search engine response
    class Result
      include Enumerable

      attr_reader :response, :current_page, :per_page, :error, :notice

      def initialize(response, options = {})
        @response = response
        @current_page = options[:page] || 1
        @per_page = options[:per_page] || ArchiveConfig.items_per_page
        @error = response[:error]
        @notice = max_search_results_notice
      end

      def items
        hits.map { |hit| hit['_source'] }
      end

      def hits
        response.dig('hits', 'hits') || []
      end

      def each(&block)
        items.each(&block)
      end

      def empty?
        items.empty?
      end

      def size
        items.size
      end

      alias length size

      def [](index)
        items[index]
      end

      def to_ary
        items
      end

      def total_pages
        return 0 if total_entries.zero? || per_page.nil?
        (total_entries / per_page.to_f).ceil
      end

      # For pagination / fetching results.
      def total_entries
        [unlimited_total_entries, ArchiveConfig.search[:max_results]].min
      end

      def unlimited_total_entries
        response.dig('hits', 'total', 'value') || 0
      end

      def offset
        (current_page * per_page) - per_page
      end

      def max_search_results_notice
        # if we're on the last page of search results AND there are more results than we can show
        return unless current_page >= total_pages && unlimited_total_entries > total_entries
        ActionController::Base.helpers.ts(
          "Displaying %{displayed} results out of %{total}. Please use the filters or edit your search to customize this list further.",
          displayed: total_entries,
          total: unlimited_total_entries
        ).html_safe
      end
    end
  end
end
