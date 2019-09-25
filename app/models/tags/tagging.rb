# frozen_string_literal: true

# Taggings connect tags to user creations, specifically
# works and bookmarks. These are the tags users themselves
# have applied to their content, whereas filter taggings are
# the connections we generate internally to provide more useful
# search and filtering results.
class Tagging < ApplicationRecord
  belongs_to :tag, foreign_key: 'tagger_id'
  belongs_to :taggable, polymorphic: true
end
