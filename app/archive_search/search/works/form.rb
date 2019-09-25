# frozen_string_literal: true

module Search
  module Works
    class Form < Search::Base::Form
      ATTRIBUTES = [
        :archive_warning_ids,
        :bookmarks_count,
        :category_ids,
        :character_names,
        :character_ids,
        :collected,
        :collection_ids,
        :comments_count,
        :complete,
        :creators,
        :crossover,
        :date_from,
        :date_to,
        :excluded_tag_names,
        :excluded_tag_ids,
        :faceted,
        :fandom_names,
        :fandom_ids,
        :filter_ids,
        :freeform_names,
        :freeform_ids,
        :hit_count,
        :kudos_count,
        :language_id,
        :other_tag_names,
        :page,
        :pseud_ids,
        :query,
        :rating_ids,
        :relationship_names,
        :relationship_ids,
        :revised_at,
        :single_chapter,
        :sort_column,
        :sort_direction,
        :title,
        :word_count,
        :words_from,
        :words_to
      ]

      ATTRIBUTES.each do |filterable|
        define_method(filterable) { options[filterable] }
      end

      # Make a direct request to the elasticsearch count api
      def self.count_for_user(user)
        Query.new(user_ids: [user.id]).count
      end

      def self.count_for_pseuds(pseuds)
        Query.new(pseud_ids: pseuds.map(&:id)).count
      end

      def query
        Query.new(options)
      end

      def process_options
        super

        set_sorting
        clean_up_angle_brackets
        add_owner
      end

      def set_sorting
        @options[:sort_column] ||= default_sort_column
        @options[:sort_direction] ||= default_sort_direction
      end

      def clean_up_angle_brackets
        %i(word_count hit_count kudos_count comments_count bookmarks_count revised_at query).each do |field|
          next if @options[field].blank?
          @options[field] = @options[field].gsub("&gt;", ">").gsub("&lt;", "<")
        end
      end

      def add_owner
        owner = options[:works_parent]
        field = case owner
                when Tag
                  :filter_ids
                when Pseud
                  :pseud_ids
                when User
                  :user_ids
                when Collection
                  :collection_ids
                end
        return unless field.present?
        options[field] ||= []
        options[field] << owner.id
      end

      def summary
        Summary.new(self).text
      end

      ###############
      # SORTING
      ###############

      SORT_OPTIONS = [
        ['Best Match', '_score'],
        ['Creator', 'authors_to_sort_on'],
        ['Title', 'title_to_sort_on'],
        ['Date Posted', 'created_at'],
        ['Date Updated', 'revised_at'],
        ['Word Count', 'word_count'],
        ['Hits', 'hit_count'],
        ['Kudos', 'kudos_count'],
        ['Comments', 'comments_count'],
        ['Bookmarks', 'bookmarks_count']
      ].freeze

      def sort_columns
        options[:sort_column] || default_sort_column
      end

      def sort_direction
        options[:sort_direction] || default_sort_direction
      end

      # Don't include 'best match' when filtering
      def sort_options
        filtering? ? SORT_OPTIONS[1..-1] : SORT_OPTIONS
      end

      def sort_values
        sort_options.map(&:last)
      end

      # extract the pretty name
      def name_for_sort_column(sort_column)
        Hash[SORT_OPTIONS.map { |v| [v[1], v[0]] }][sort_column]
      end

      # Default to date if we're filtering and
      # default to relevance if we're searching
      def default_sort_column
        filtering? ? 'revised_at' : '_score'
      end

      # Text values sort up, dates and numbers sort down by default
      def default_sort_direction
        if %w(authors_to_sort_on title_to_sort_on).include?(sort_column)
          'asc'
        else
          'desc'
        end
      end

      # Is this a page with filtering?
      def filtering?
        options[:faceted] || options[:collected]
      end
    end
  end
end
