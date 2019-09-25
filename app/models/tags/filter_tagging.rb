# frozen_string_literal: true

class FilterTagging < ApplicationRecord
  belongs_to :filter, class_name: 'Tag'
  belongs_to :filterable, polymorphic: true

  validates_presence_of :filter, :filterable
end
