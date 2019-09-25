# frozen_string_literal: true

# Shared code for classes which act as creations
# currently: chapters, series, and works
module Creation
  extend ActiveSupport::Concern

  included do
    has_many :creatorships, as: :creation
    has_many :pseuds, through: :creatorships
  end

  class_methods do
    def users
      User.joins(:creatorships).where(
        creation_type: self.class,
        creation_id: self.id
      )
    end
  end
end
