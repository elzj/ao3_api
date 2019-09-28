# frozen_string_literal: true

# Shares validation code between works and work-related models
module Autocompleted
  extend ActiveSupport::Concern

  included do
  end

  class_methods do
    # A little string parsing utility
    # to handle comma-separated lists
    def words_from_list(list)
      return [] if list.blank?
      list.split(',').map(&:squish).uniq.select(&:present?)
    end
  end
end
