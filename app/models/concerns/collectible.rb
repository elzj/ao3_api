# frozen_string_literal: true

# Shared code for classes which may be added to collections
# currently: works and bookmarks
module Collectible
  extend ActiveSupport::Concern

  included do
    has_many :collection_items, as: :item
    has_many :collections, through: :collection_items
  end

  class_methods do
  end

  def approved_collections
    collections.merge(CollectionItem.approved)
  end
end
