# frozen_string_literal: true

# Shared code for classes which can be bookmarked
# currently: works, series, and external works
module Bookmarkable
  extend ActiveSupport::Concern

  included do
    has_many :bookmarks, as: :bookmarkable

    after_commit :reindex_as_bookmarkable
  end

  class_methods do
  end

  def public_bookmark_count
    bookmarks.where(private: false).count
  end

  def reindex_as_bookmarkable
    Search::Bookmarks::ParentIndexer.reindex(self)
  end

  def sortable_date
    respond_to?(:revised_at) ? revised_at : updated_at
  end
end
