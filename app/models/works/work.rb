# frozen_string_literal: true

class Work < ApplicationRecord
  include Collectible
  include Creation
  include Taggable

  ### ASSOCIATIONS ###
  
  belongs_to :language

  has_many :chapters

  has_many :serial_works
  has_many :series, through: :serial_works

  has_one :stat_counter

  ### VALIDATIONS ###

  validates :endnotes,
            length: { maximum: ArchiveConfig.works[:notes_max] }
  validates :notes,
            length: { maximum: ArchiveConfig.works[:notes_max] }
  validates :summary,
            length: { maximum: ArchiveConfig.works[:summary_max] }
  validates :title,
            presence: true,
            length: {
              minimum: ArchiveConfig.works[:title_min],
              maximum: ArchiveConfig.works[:title_max]
            }

  ### CALLBACKS ###

  before_validation :clean_title

  ### CLASS METHODS ###

  def self.posted
    where(posted: true)
  end

  ### INSTANCE METHODS ###

  # creates a language_short method
  delegate :short, to: :language, prefix: true, allow_nil: true

  def clean_title
    self.title = (title || '').strip
  end
end
