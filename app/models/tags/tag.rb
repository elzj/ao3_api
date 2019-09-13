# frozen_string_literal: true

class Tag < ApplicationRecord
  TAGGABLE_TYPES = %w[
    Rating Warning Category Fandom Character Relationship Freeform
  ].freeze
  ALL_TYPES = TAGGABLE_TYPES + ['Media']

  ### ASSOCIATIONS
  has_many :taggings,
    foreign_key: :tagger_id
  has_many :works,
    through: :taggings,
    source: :taggable,
    source_type: 'Work'

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

  ### CLASS METHODS

  # Workaround for warning class with existing data
  def self.find_sti_class(type_name)
    if type_name == 'Warning'
      ArchiveWarning
    else
      super
    end
  end

  ### INSTANCE METHODS
  def has_posted_works?
    works.where(posted: true).exists?
  end

  def syn
    Tag.where(id: merger_id).first if merger_id
  end

  def syns
    Tag.where(merger_id: id)
  end

  def direct_meta_tags
    meta_tags.where(meta_taggings: { direct: 1 })
  end

  def direct_sub_tags
    sub_tags.where(meta_taggings: { direct: 1 })
  end
end
