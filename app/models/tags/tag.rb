# frozen_string_literal: true

class Tag < ApplicationRecord
  TAGGABLE_TYPES = %w[
    Rating Warning Category Fandom Character Relationship Freeform
  ].freeze
  ALL_TYPES = TAGGABLE_TYPES + ['Media']

  ### ASSOCIATIONS
  has_many :taggings, foreign_key: :tagger_id
  has_many :works, through: :taggings, source: :taggable, source_type: 'Work'


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
end
