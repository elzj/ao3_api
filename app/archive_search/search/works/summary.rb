# frozen_string_literal: true

module Search
  module Works
    # Generates a text summary of the search for display
    class Summary
      def initialize(search_form)
        @search_form = search_form
        @lines = []
      end

      def query
        @search_form.query
      end

      def options
        @search_form.options
      end

      def text
        construct_summary
        @lines.uniq.join(" ")
      end

      def construct_summary
        add_query
        add_title
        add_creators
        add_tags
        add_complete
        add_crossovers
        add_single_chapter
        add_language
        add_countables
        add_sorting
      end

      def add_query
        return if options[:query].blank?
        @lines << options[:query]
      end

      def add_title
        return if options[:title].blank?
        @lines << "Title: #{options[:title]}"
      end

      def add_creators
        return if options[:creators].blank?
        @lines << "Creator: #{options[:creators]}"
      end

      def add_tags
        tags = query.included_tag_names
        all_tag_ids = query.filter_ids
        unless all_tag_ids.empty?
          tags << Tag.where(id: all_tag_ids).pluck(:name).join(", ")
        end
        @lines << "Tags: #{tags.uniq.join(', ')}" if tags.present?
      end

      def add_complete
        if options[:complete] == "T"
          @lines << "Complete"
        elsif options[:complete] == "F"
          @lines << "Incomplete"
        end
      end

      def add_crossovers
        if options[:crossover] == "T"
          @lines << "Only Crossovers"
        elsif options[:crossover] == "F"
          @lines << "No Crossovers"
        end
      end

      def add_single_chapter
        return if options[:single_chapter].blank?
        @lines << "Single Chapter"
      end

      def add_language
        return if options[:language_id].blank?
        language = Language.find_by(short: options[:language_id])
        @lines << "Language: #{language.name}" if language
      end

      def add_countables
        %i(word_count hits kudos_count comments_count bookmarks_count revised_at).each do |field|
          next if options[field].blank?
          @lines << "#{field.to_s.humanize.downcase}: #{options[field]}"
        end
      end

      def add_sorting
        @lines += [sort_column, sort_direction].compact
      end

      def sort_column
        return if options[:sort_column].blank?
        column = @search_form.name_for_sort_column(options[:sort_column])
        "sort by: #{column.downcase}"
      end

      def sort_direction
        return if options[:sort_direction].blank?
        options[:sort_direction] == "asc" ? "ascending" : "descending"
      end
    end
  end
end
