# frozen_string_literal: true

class Creatorship < ApplicationRecord
  ### ASSOCIATIONS
  belongs_to :pseud
  belongs_to :creation, polymorphic: true

  ### VALIDATIONS

  ### CALLBACKS

  ### CLASS METHODS

  ## INSTANCE METHODS
end
