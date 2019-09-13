# frozen_string_literal: true

# Parent Taggings connect tags of different types:
# a fandom tag (Star Trek) might belong to a media tag (TV)
# typically the chain goes media > fandom > character > relationship
# but relationships and freeforms can also belong directly to fandoms
class ParentTagging < ApplicationRecord
  self.table_name = "common_taggings"

  belongs_to :child_tag,
    class_name: 'Tag',
    foreign_key: 'common_tag_id',
    touch: true
  belongs_to :parent_tag,
    class_name: 'Tag',
    foreign_key: 'filterable_id',
    touch: true

  validates_presence_of :child_tag, :parent_tag
  validates_uniqueness_of :common_tag_id, scope: :filterable_id
end
