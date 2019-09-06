class Work < ApplicationRecord
  ### ASSOCIATIONS ###

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

  ### INSTANCE METHODS ###

  def clean_title
    self.title = (self.title || "").strip
  end
end