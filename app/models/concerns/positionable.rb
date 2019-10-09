# frozen_string_literal: true

# Shared code for classes with a position attribute
module Positionable
  extend ActiveSupport::Concern

  class_methods do
    # Keep things in order and avoid overlapping positions
    def reposition!(relation)
      relation.in_order.each_with_index do |item, i|
        item.position = i + 1
        if item.position_changed?
          item.update_column(:position, item.position)
        end
      end
    end

    def in_order
      order(position: :asc, updated_at: :desc)
    end
  end
end
