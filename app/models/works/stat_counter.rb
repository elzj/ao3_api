# frozen_string_literal: true

# Cache class for work statistics
class StatCounter < ApplicationRecord
  belongs_to :work
end
