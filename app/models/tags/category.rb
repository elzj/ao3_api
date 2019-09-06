# frozen_string_literal: true

class Category < Tag
  DEFAULTS = [
    'Gen', 'F/F', 'F/M', 'M/M', 'Multi', 'Other'
  ].freeze
  validates :name, inclusion: { in: DEFAULTS }
end
