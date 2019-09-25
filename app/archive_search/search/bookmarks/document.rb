# frozen_string_literal: true

module Search
  module Bookmarks
    class Document < Search::Base::Document
    end
  end
end

# module Bookmarks
#   class Document < SimpleDelegator

#     WHITELISTED_FIELDS = [
#       :id, :created_at, :bookmarkable_type, :bookmarkable_id, :user_id,
#       :notes, :private, :updated_at, :hidden_by_admin, :pseud_id, :rec
#     ]

#     INCLUDED_METHODS = [
#       :bookmarker, :collection_ids, :with_notes, :bookmarkable_date
#     ]

#     def as_json(options = nil)
#       bookmark.as_json(
#         root:     false,
#         only:     WHITELISTED_FIELDS,
#         methods:  INCLUDED_METHODS
#       ).merge(
#         user_id:  user_id,
#         tag:      tag_names,
#         tag_ids:  tags_ids
#       ).merge(bookmarkable)
#     end

#     def bookmark
#       __getobj__
#     end

#     def bookmarkable
#       if parent_id.match("deleted")
#         {}
#       else
#         {
#           bookmarkable_join: {
#             name: "bookmark",
#             parent: parent_id
#           }
#         }
#       end
#     end

#     def parent_id
#       if bookmark.nil?
#         deleted_parent_info
#       else
#         [
#           bookmark.bookmarkable_id,
#           bookmark.bookmarkable_type.underscore
#         ].join("-")
#       end
#     end

#     def deleted_parent_info
#       REDIS_GENERAL.get("deleted_bookmark_parent_#{bookmark.id}")
#     end
#   end
# end
