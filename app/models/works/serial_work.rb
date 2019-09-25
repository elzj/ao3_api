# frozen_string_literal: true

class SerialWork < ApplicationRecord
  belongs_to :series
  belongs_to :work
end
