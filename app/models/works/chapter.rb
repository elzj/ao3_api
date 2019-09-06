# frozen_string_literal: true

class Chapter < ApplicationRecord
  ### ASSOCIATIONS
  has_many :creatorships, as: :creation
  has_many :pseuds, through: :creatorships
  belongs_to :work  

  ### VALIDATIONS
  validates :content,
            presence: true,
            length: {
              minimum: ArchiveConfig.chapters[:content_min]
            }
  validates :endnotes,
            length: {
              maximum: ArchiveConfig.works[:notes_max]
            }
  validates :notes,
            length: {
              maximum: ArchiveConfig.works[:notes_max]
            }
  validates :summary,
            length: {
              maximum: ArchiveConfig.works[:summary_max]
            }
  validates :title,
            length: {
              maximum: ArchiveConfig.works[:title_max]
            }

  ### CALLBACKS
  before_validation :clean_title

  ### CLASS METHODS
  def self.in_order
    order(:position)
  end

  def self.posted
    where(posted: true)
  end

  ### INSTANCE METHODS
  def clean_title
    self.title = title.strip if title
  end
end
