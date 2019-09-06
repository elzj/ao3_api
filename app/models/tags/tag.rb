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

  # Workaround for warning class with existing data
  def self.find_sti_class(type_name)
    if type_name == "Warning"
      ArchiveWarning
    else
      super
    end
  end

  ### INSTANCE METHODS

end