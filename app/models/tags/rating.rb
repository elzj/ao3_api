# frozen_string_literal: true

class Rating < Tag
  DEFAULTS = [
    'General Audiences',
    'Teen And Up Audiences',
    'Mature',
    'Explicit',
    'Not Rated'
  ].freeze
  validates :name, inclusion: { in: DEFAULTS }
end
