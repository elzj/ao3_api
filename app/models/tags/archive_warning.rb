class ArchiveWarning < Tag
  DEFAULTS = [
    "No Archive Warnings Apply",
    "Rape/Non-Con",
    "Graphic Depictions Of Violence",
    "Major Character Death",
    "Underage",
    "Choose Not To Use Archive Warnings"
  ]

  ### VALIDATIONS

  validates :name, inclusion: { in: DEFAULTS }

  ### CLASS METHODS

  # Make it work with legacy Warning data until migration is complete
  def self.sti_name
    'Warning'
  end
end