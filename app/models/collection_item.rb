# frozen_string_literal: true

# Join table which connects collections with works/bookmarks
class CollectionItem < ApplicationRecord
  NEUTRAL = 0
  APPROVED = 1
  REJECTED = -1

  ### ASSOCIATIONS ###

  belongs_to :collection
  belongs_to :item, polymorphic: true

  ### CLASS METHODS ###

  # Scope for fully-approved items  
  def self.approved
    where(
      user_approval_status: APPROVED,
      collection_approval_status: APPROVED
    )
  end
end
