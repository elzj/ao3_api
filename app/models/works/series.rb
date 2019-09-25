# frozen_string_literal: true

class Series < ApplicationRecord
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
