# frozen_string_literal: true

# Meta Taggings connect tags of the same type when those tags are
# considered subsets of one another. Individual entries in a franchise,
# for instance, might have a meta tag connecting them.
# 'John' might be a meta tag for 'John Smith', 'John Doe', etc.
class MetaTagging < ApplicationRecord
  belongs_to :meta_tag, class_name: 'Tag'
  belongs_to :sub_tag, class_name: 'Tag'

  validates_presence_of :meta_tag, :sub_tag
  validates_uniqueness_of :meta_tag_id,
                          scope: :sub_tag_id
end
