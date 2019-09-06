class Category < Tag
  DEFAULTS = [
    'Gen', 'F/F', 'F/M', 'M/M', 'Multi', 'Other'
  ]
  validates :name, inclusion: { in: DEFAULTS }
end
