# frozen_string_literal: true

class MetaTagging < ApplicationRecord
  belongs_to :meta_tag, class_name: 'Tag'
  belongs_to :sub_tag, class_name: 'Tag'

  validates_presence_of :meta_tag, :sub_tag
  validates_uniqueness_of :meta_tag_id,
                          scope: :sub_tag_id
end
