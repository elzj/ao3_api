# frozen_string_literal: true

class Work < ApplicationRecord
  include Bookmarkable
  include Collectible
  include Creatable
  include Sanitized
  include Taggable

  sanitize_fields title:    [:html_entities],
                  notes:    [:html, :css],
                  endnotes: [:html, :css],
                  summary:  [:html]

  searchkick mappings: WorkSearch.mappings,
             settings: WorkSearch.settings

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

  def self.unhidden
    where(hidden_by_admin: false)
  end

  def self.unrestricted
    where(restricted: false)
  end

  ### INSTANCE METHODS ###

  # creates a language_short method
  delegate :short, to: :language, prefix: true, allow_nil: true

  def clean_title
    self.title = (title || '').strip
  end

  def search_data
    WorkSearch.document(self)
  end

  def set_completeness
    posted_chapter_count = chapters.select { |c| c.posted? }.length
    self.complete = (posted_chapter_count == chapters_expected)
  end

  def set_word_count
    posted_word_counts = chapters.map { |c| c.posted? ? c.word_count : 0 }
    self.word_count = posted_word_counts.sum
  end

  alias_attribute :anonymous?, :in_anon_collection
  alias_attribute :unrevealed?, :in_unrevealed_collection
  alias_attribute :chapters_expected, :expected_number_of_chapters
end
