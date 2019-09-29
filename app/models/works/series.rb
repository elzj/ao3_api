# frozen_string_literal: true

class Series < ApplicationRecord
  include Bookmarkable
  include Creatable
  include Sanitized

  sanitize_fields title:        [:html_entities],
                  series_notes: [:html, :css],
                  summary:      [:html]

  has_many :serial_works
  has_many :works, through: :serial_works

  ### VALIDATIONS ###

  validates :series_notes, length: {
    allow_blank: true,
    maximum: ArchiveConfig.series[:notes_max]
  }

  validates :summary, length: {
    allow_blank: true,
    maximum: ArchiveConfig.series[:summary_max]
  }

  validates :title,
            presence: true,
            length: { maximum: ArchiveConfig.series[:title_max] }
end
