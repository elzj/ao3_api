# frozen_string_literal: true

class Collection < ApplicationRecord
  include Sanitized

  sanitize_fields description: [:html]

  searchkick

  ### ASSOCIATIONS ###

  belongs_to :parent,
             class_name: "Collection",
             optional: true

  has_many :children,
           class_name: "Collection",
           foreign_key: "parent_id"
  has_many :collection_items
  has_many :works,
           through: :collection_items,
           source: :item,
           source_type: 'Work'

  ### VALIDATIONS ###

  validates :name,
            presence: true,
            uniqueness: { case_sensitive: false },
            length: { maximum: ArchiveConfig.collections[:name_max] },
            format: { with: /\A[A-Za-z0-9]\w*[A-Za-z0-9]\Z/ }

  validates :title,
            presence: true,
            length: { maximum: ArchiveConfig.collections[:title_max] },
            format: {
              with: /\A[^\,]+\Z/,
              message: "cannot contain commas"
            }

  ### CLASS METHODS ###

  ### INSTANCE METHODS ###

  # Return only works that have been approved by the user
  # and by the collection itself
  def approved_works
    works.merge(CollectionItem.approved).posted
  end
end
