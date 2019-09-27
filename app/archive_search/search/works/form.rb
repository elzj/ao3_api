# frozen_string_literal: true

module Search
  module Works
    # Form interface for work searches    
    class Form < Search::Base::Form
      TAG_FIELDS = %i(
        archive_warning_ids category_ids rating_ids
        character_names character_ids
        fandom_names fandom_ids
        freeform_names freeform_ids
        relationship_names relationship_ids
        excluded_tag_names excluded_tag_ids
        tag_names filter_ids
      ).freeze

      NUMBER_AND_DATE_FIELDS = %i(
        bookmarks_count comments_count kudos_count hit_count
        date_from date_to revised_at
        word_count words_from words_to
      ).freeze

      ASSOCIATION_FIELDS = %i(
        collection_ids language_id pseud_ids user_ids
      ).freeze

      GENERAL_FIELDS = %i(
        complete creators crossover
        page q single_chapter
        sort_column sort_direction title
        filtered collected works_parent current_user
      ).freeze

      ATTRIBUTES = (
        TAG_FIELDS +
        NUMBER_AND_DATE_FIELDS +
        ASSOCIATION_FIELDS +
        GENERAL_FIELDS
      ).freeze

      attr_accessor(*ATTRIBUTES)

      def self.permitted_params
        ATTRIBUTES
      end

      # Make a direct request to the elasticsearch count api
      def self.count_for_user(user)
        query_class.new(user_ids: [user.id]).count
      end

      def self.count_for_pseuds(pseuds)
        query_class.new(pseud_ids: pseuds.map(&:id)).count
      end

      def query_class
        Query
      end

      def process_data
        super

        set_sorting
        clean_up_angle_brackets
        add_owner
        load_tags
      end

      # Numeric fields to sanitize
      def number_fields
        %i(words_to words_from)
      end

      # Date fields to sanitize
      def date_fields
        %i(date_to date_from)
      end

      # Boolean fields to sanitize
      def boolean_fields
        %i(complete crossover single_chapter)
      end

      def set_sorting
        unless legal_sort_values.includes?(sort_column)
          self.sort_column = default_sort_column
        end
        return if sort_direction && %w(asc desc).includes?(sort_direction.downcase)
        self.sort_direction = default_sort_direction
      end

      def clean_up_angle_brackets
        %i(word_count hit_count kudos_count comments_count bookmarks_count revised_at query_string).each do |field|
          value = send(field)
          next if value.blank?
          self.send("#{field}=", value.gsub("&gt;", ">").gsub("&lt;", "<"))
        end
      end

      def add_owner
        field = case works_parent
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
        value = send(field) || []
        send("#{field}=", value + [owner.id])
      end

      def load_tags
        ids = Tag::TAGGABLE_TYPES.flat_map do |tag_type|
          send("#{tag_type.underscore}_ids")
        end
        self.filter_ids = (
          [self.filter_ids] + ids + processed_tag_name_ids
        ).flatten.compact.uniq
        process_exclusions
      end

      def processed_tag_name_ids
        names = parse_tag_names
        tags = Tag.where(name: names).pluck(:id, :name)
        # Use our non-user-facing field to hold the missing
        self.tag_names = names - tags.map(&:last)
        tags.map(&:first)
      end

      def parse_tag_names
        tag_name_fields = %w(
          fandom_names character_names relationship_names
          freeform_names tag_names
        )
        tag_name_fields.flat_map do |field|
          value = send(field)
          next if value.blank?
          value.split(',').map(&:squish).reject(&:blank?)
        end.uniq.compact
      end

      def process_exclusions
        value = self.excluded_tag_names
        return unless value
        names = value.split(',').map(&:squish).reject(&:blank?)
        return if names.blank?
        ids = Tag.where(name: names).pluck(:id)
        self.excluded_tag_ids ||= []
        self.excluded_tag_ids << ids
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

      # Don't include 'best match' when filtering
      def sort_options
        filtering? ? SORT_OPTIONS[1..-1] : SORT_OPTIONS
      end

      def legal_sort_values
        sort_options.map(&:last)
      end

      # extract the pretty name
      def name_for_sort_column(column)
        Hash[SORT_OPTIONS.map { |v| [v[1], v[0]] }][column]
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
        filtered
      end
    end
  end
end
