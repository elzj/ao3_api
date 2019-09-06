class ArchiveWarning < Tag
  class << self
    def sti_name
      'Warning'
    end
  end

  DEFAULTS = [
    "No Archive Warnings Apply",
    "Rape/Non-Con",
    "Graphic Depictions Of Violence",
    "Major Character Death",
    "Underage",
    "Choose Not To Use Archive Warnings"
  ]
end