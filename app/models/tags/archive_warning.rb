# frozen_string_literal: true

class ArchiveWarning < Tag
  DEFAULTS = [
    'No Archive Warnings Apply',
    'Rape/Non-Con',
    'Graphic Depictions Of Violence',
    'Major Character Death',
    'Underage',
    'Choose Not To Use Archive Warnings'
  ].freeze

  ### VALIDATIONS

  validates :name, inclusion: { in: DEFAULTS }

  ### CLASS METHODS
end
