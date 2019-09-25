# frozen_string_literal: true

class Language < ApplicationRecord
  ### ASSOCIATIONS ###

  validates :name, presence: true
  validates :short,
            presence: true,
            uniqueness: {
              case_sensitive: false
            }
  validates :sortable_name, presence: true

  ### CALLBACKS ###

  before_validation :set_sortable_name

  ### CLASS METHODS ###

  ### INSTANCE METHODS ###

  def set_sortable_name
    return if sortable_name.present? || short.blank?
    self.sortable_name = short.downcase
  end
end
