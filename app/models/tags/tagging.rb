# frozen_string_literal: true

class Tagging < ApplicationRecord
  belongs_to :tag, foreign_key: 'tagger_id'
  belongs_to :taggable, polymorphic: true
end
