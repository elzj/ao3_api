# frozen_string_literal: true

module Search
  module Bookmarks
    module Settings
      MAPPINGS = {
        "properties" => {
          "bookmarkable_join" => {
            "type" => "join",
            "relations" => {
              "bookmarkable" => "bookmark"
            }
          },
          "title" => {
            "type" => "text",
            "analyzer" => "simple"
          },
          "work_types" => {
            "type" => "keyword"
          },
          "bookmarkable_type" => {
            "type" => "keyword"
          }
        }
      }.freeze

      SETTINGS = {
        index: {
          number_of_shards: ArchiveConfig.search[:bookmark_shards],
          max_result_window: ArchiveConfig.search[:max_results]
        }
      }.freeze
    end
  end
end
