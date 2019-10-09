# frozen_string_literal: true

module Search
  # The main interface between the model and the custom search code
  class WorkSearch
    include ActiveModel::Model
    include Search::Works::Settings
    include Search::Shared::SearchMethods
    include Search::Shared::TaggableSearch

    TAG_FIELDS = %w(
      archive_warning_ids category_ids rating_ids
      character_names character_ids
      fandom_names fandom_ids
      freeform_names freeform_ids
      relationship_names relationship_ids
      excluded_tag_names excluded_tag_ids
      tag_names filter_ids
    ).freeze

    NUMBER_AND_DATE_FIELDS = %w(
      bookmarks_count comments_count kudos_count hit_count
      date_from date_to revised_at
      word_count words_from words_to
    ).freeze

    ASSOCIATION_FIELDS = %w(
      collection_ids language_id pseud_ids user_ids
    ).freeze

    GENERAL_FIELDS = %w(
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

    def attributes
      self.as_json(only: ATTRIBUTES)
    end

    def self.permitted_params
      ATTRIBUTES.map do |att|
        if att.match(/_ids|_names/)
          { att => [] }
        else
          att
        end
      end
    end

    # The JSON document to be indexed
    def self.document(tag)
      Search::Works::Document.new(tag).as_json
    end

    def self.mappings
      MAPPINGS
    end

    def self.settings
      SETTINGS
    end

    def client
      @client ||= Search::Client.new_client
    end

    # Generate an elasticsearch query
    def search_body
      process_input unless processed?
      Search::Works::Query.new(attributes).to_hash
    end

    # Pass our query to the searchkick search method
    def search_results(load: false)
      if load
        Work.search(body: search_body, load: load)
      else
        Search::Result.new(
          wrapper: WorkBlurb,
          response: client.search(
            index: Work.searchkick_index.name,
            body: search_body
          ),
          page: page || 1
        )
      end
    end

    def summary
      Search::Works::Summary.new(self).text
    end

    def process_input
      sanitize_input
      set_sorting
      clean_up_angle_brackets
      add_owner
      load_tags
      @processed = true
    end

    def sanitize_input
      %i(words_to words_from).each do |field|
        sanitize_field(field, :sanitize_integer)
      end
      %i(date_to date_from).each do |field|
        sanitize_field(field, :sanitize_date)
      end
      %i(complete crossover single_chapter).each do |field|
        sanitize_field(field, :bool_value)
      end
    end

    def clean_up_angle_brackets
      %i(word_count hit_count kudos_count comments_count bookmarks_count revised_at q).each do |field|
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

    ### SORTING ###

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

    def processed?
      @processed
    end
  end
end
