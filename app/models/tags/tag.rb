class Tag < ApplicationRecord
  TAGGABLE_TYPES = %w(Rating Warning Category Character Relationship Freeform).freeze

  ### ASSOCIATIONS
  has_many :taggings, foreign_key: :tagger_id

  ### VALIDATIONS
  validates :name,
    presence: true,
    uniqueness: { case_sensitive: false },
    length: {
      minimum: ArchiveConfig.tags[:name_min],
      maximum: ArchiveConfig.tags[:name_max]
    }

  validates :type,
    inclusion: { in: TAGGABLE_TYPES }

  ### CALLBACKS

  ### CLASS METHODS

  ### INSTANCE METHODS
end