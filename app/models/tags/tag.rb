# frozen_string_literal: true

class Tag < ApplicationRecord
  TAGGABLE_TYPES = %w(
    Rating Warning Category Fandom Character Relationship Freeform
  ).freeze
  ALL_TYPES = TAGGABLE_TYPES + ['Media']

  include StringCleaner

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

  ### CLASS METHODS

  def self.by_type(tag_type)
    where(type: tag_type)
  end

  # Workaround for warning class with existing data
  def self.find_sti_class(type_name)
    if type_name == 'Warning'
      ArchiveWarning
    else
      super
    end
  end

  def self.with_direct_filtered_works
    joins(:filtered_works).where(filter_taggings: { inherited: false })
  end

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

  ### INSTANCE METHODS

  def squish_name
    self.name = name.squish if self.name
  end

  def set_sortable_name
    self.sortable_name = remove_articles_from_string(self.name)
  end

  ### INSTANCE METHODS ###

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
