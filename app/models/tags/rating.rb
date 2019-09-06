class Rating < Tag
  DEFAULTS = [
    "General Audiences",
    "Teen And Up Audiences",
    "Mature",
    "Explicit",
    "Not Rated"
  ]
  validates :name, inclusion: { in: DEFAULTS }
end