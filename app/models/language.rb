# frozen_string_literal: true

class Language < ApplicationRecord
  AVAILABLE = {
    de: "Deutsch",
    en: "English",
    es: "Espanol"
  }
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

  def self.name_for_short(short)
    AVAILABLE[short] || "English"
  end

  ### INSTANCE METHODS ###

  def set_sortable_name
    return if sortable_name.present? || short.blank?
    self.sortable_name = short.downcase
  end
end
