# frozen_string_literal: true

class Chapter < ApplicationRecord
  include Creatable
  include Sanitized

  sanitize_fields title:    [:html_entities],
                  notes:    [:html, :css],
                  endnotes: [:html, :css],
                  summary:  [:html],
                  content:  [:html, :css, :multimedia]

  ### ASSOCIATIONS
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
