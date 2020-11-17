# frozen_string_literal: true

class Chapter < ApplicationRecord
  include Creatable
  include Positionable
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
  before_validation :clean_title, :count_words
  after_commit :queue_callbacks

  ### CLASS METHODS
  def self.posted
    where(posted: true)
  end

  def self.update_positions(work_id)
    return unless work_id
    reposition!(where(work_id: work_id))
  end

  ### INSTANCE METHODS
  def clean_title
    self.title = title.strip if title
  end

  def count_words
    self.word_count = Otw::WordCounter.new(content).count
  end

  # Put callbacks that affect other models here
  def queue_callbacks
    ChapterPostingJob.perform_later(self)
  end
end
