# frozen_string_literal: true

module Search
  module Works
    # Generates a text summary of the search for display
    class Summary
      attr_reader :form

      def initialize(form)
        @form = form
        @lines = []
      end

      def text
        form.process_input unless form.processed?
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
        return if form.q.blank?
        @lines << form.q
      end

      def add_title
        return if form.title.blank?
        @lines << "Title: #{form.title}"
      end

      def add_creators
        return if form.creators.blank?
        @lines << "Creator: #{form.creators}"
      end

      def add_tags
        ids = form.filter_ids
        tags = []
        if ids.present?
          tags << Tag.where(id: ids).pluck(:name).join(", ")
        end
        @lines << "Tags: #{tags.uniq.join(', ')}" if tags.present?
      end

      def add_complete
        if form.complete
          @lines << "Complete"
        elsif !form.complete.nil?
          @lines << "Incomplete"
        end
      end

      def add_crossovers
        if form.crossover
          @lines << "Only Crossovers"
        elsif !form.crossover.nil?
          @lines << "No Crossovers"
        end
      end

      def add_single_chapter
        @lines << "Single Chapter" if form.single_chapter
      end

      def add_language
        return if form.language_id.blank?
        language = Language.find_by(short: form.language_id)
        @lines << "Language: #{language.name}" if language
      end

      def add_countables
        %i(word_count hit_count kudos_count comments_count bookmarks_count revised_at).each do |field|
          value = form.send(field)
          next if value.blank?
          @lines << "#{field.to_s.humanize.downcase}: #{value}"
        end
      end

      def add_sorting
        @lines += [
          sort_column,
          sort_direction
        ].compact
      end

      def sort_column
        return if form.sort_column.blank?
        column = form.name_for_sort_column(form.sort_column)
        "sort by: #{column.downcase}"
      end

      def sort_direction
        return if form.sort_direction.blank?
        form.sort_direction == "asc" ? "ascending" : "descending"
      end
    end
  end
end
