# frozen_string_literal: true

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  # Pluck returns an array of values, but sometimes you'd like
  # the data as a hash without the overhead of instantiating the object
  def self.pluck_as_hash(*atts)
    pluck(*atts).map { |values| atts.zip(values).to_h }
  end
end
