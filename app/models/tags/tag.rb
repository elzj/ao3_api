# frozen_string_literal: true

class Tag < ApplicationRecord
  TAGGABLE_TYPES = %w(
    Rating ArchiveWarning Category Fandom Character Relationship Freeform
  ).freeze
  ALL_TYPES = TAGGABLE_TYPES + ['Media']

  include Autocompleted
  include StringCleaner

  searchkick mappings: Search::TagSearch.mappings,
             settings: Search::TagSearch.settings

  ### ASSOCIATIONS

  # Direct uses of tags on user content
  has_many :taggings,
           foreign_key: :tagger_id
  has_many :works,
           through: :taggings,
           source: :taggable,
           source_type: 'Work'

  # Under-the-hood connections between tags and user content
  # based on tag wrangling data (canonicals and meta tags)
  has_many :filter_taggings,
           foreign_key: :filter_id
  has_many :filtered_works,
           through: :filter_taggings,
           source: :filterable,
           source_type: 'Work'

  # These are the tag wrangling relationships
  # between tags of different types
  has_many :parent_taggings,
           foreign_key: 'common_tag_id'
  has_many :child_taggings,
           class_name: 'ParentTagging',
           foreign_key: 'filterable_id'
  has_many :children,
           through: :child_taggings,
           source: :child_tag
  has_many :parents,
           through: :parent_taggings,
           source: :parent_tag

  # And these are meta tag relationships
  # between tags of the same type
  has_many :meta_taggings,
           foreign_key: 'sub_tag_id'
  has_many :meta_tags,
           through: :meta_taggings,
           source: :meta_tag
  has_many :sub_taggings,
           class_name: 'MetaTagging',
           foreign_key: 'meta_tag_id'
  has_many :sub_tags,
           through: :sub_taggings,
           source: :sub_tag

  ### VALIDATIONS

  validates :name,
            presence: true,
            uniqueness: { case_sensitive: false },
            length: {
              minimum: ArchiveConfig.tags[:name_min],
              maximum: ArchiveConfig.tags[:name_max]
            }

  validates :type,
            inclusion: { in: ALL_TYPES }

  ### CALLBACKS

  before_validation :squish_name
  before_validation :set_sortable_name

  ### CLASS METHODS ###

  ## GENERAL UTILITIES ##

  def self.autocomplete_buckets
    [
      "autocomplete_#{self.name.underscore}",
      "autocomplete_tag"
    ].uniq
  end

  def self.autocomplete_fields
    [:name]
  end

  ## FINDERS ##

  # Find tags by type
  def self.by_type(tag_type)
    where(type: tag_type)
  end

  # Given a pseud, find tags (as filters) used on its works
  # with the count as a virtual attribute
  def self.for_pseud_with_count(pseud, type: nil, unrestricted: nil)
    select_list = "tags.id, tags.name, tags.type, COUNT('tags.id') AS count"
    query = with_direct_filtered_works.
              joins(filtered_works: :creatorships).
              select(select_list).
              where(
                creatorships: { pseud_id: pseud.id, approved: true },
                works: {
                  in_anon_collection: false,
                  in_unrevealed_collection: false
                }
              ).merge(Work.posted.unhidden)
    query = query.where(type: type) if type
    query = query.merge(Work.unrestricted) if unrestricted
    query.group(:id)
  end

  # Includes direct filtered works in a relation
  def self.with_direct_filtered_works
    joins(:filtered_works).where(filter_taggings: { inherited: false })
  end

  ## ACTION METHODS ##

  # Given a type and a list of names, find or create the tags
  # and return as an array
  def self.create_multiple(tag_type, names)
    raise "Invalid tag type" unless ALL_TYPES.include?(tag_type)

    names.map do |name|
      Tag.where(type: tag_type, name: name).first_or_create
    end
  end

  # Given a type and a comma-separated list of tag names, find or create them
  # It's important to return the list in the original order
  def self.process_tag_list(tag_type, tag_string)
    names = words_from_list(tag_string)

    # Using the original array keeps things in order
    tags = tags_for_names(tag_type, names).group_by(&:name)
    names.flat_map { |name| tags[name] }.uniq.compact
  end

  # Finds or creates tags by name for a given type
  # Needs to handle the situation where a tag with a certain name
  # exists as a different type
  def self.tags_for_names(tag_type, names)
    found = Tag.where(name: names)
    tags, wrong_type = found.partition { |tag| tag.type == type }

    new_tags = names - tags.map(&:name)
    new_tags += wrong_type.map { |tag| "#{tag.name} - #{tag_type}" }

    tags + create_multiple(tag_type, new_tags)
  end

  ### INSTANCE METHODS

  def squish_name
    self.name = name.squish if self.name
  end

  def set_sortable_name
    self.sortable_name = remove_articles_from_string(self.name)
  end

  ### INSTANCE METHODS ###

  def autocomplete_score
    uses
  end

  def has_posted_works?
    works.posted.exists?
  end

  def parent_ids(tag_type)
    parents.by_type(tag_type).pluck(:id, :type).map(&:first)
  end

  # Can be set by subclasses
  def parent_types
    []
  end

  # Create a tag document for indexing
  def search_data
    Search::TagSearch.document(self)
  end

  def suggested_parent_ids(tag_type)
    []
  end

  def syn
    Tag.where(id: merger_id).first if merger_id
  end

  def syns
    Tag.where(merger_id: id)
  end

  def uses
    taggings_count_cache
  end
end
