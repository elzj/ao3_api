# frozen_string_literal: true

module Search
  module Pseuds
    module Settings
      MAPPINGS = {
        properties: {
          name: {
            type: "text",
            analyzer: "simple"
          },
          sortable_name: {
            type: "keyword"
          },
          byline: {
            type: "text",
            analyzer: "standard"
          },
          user_login: {
            type: "text",
            analyzer: "simple"
          },
          tags: {
            type: "object"
          },
          public_tags: {
            type: "object"
          }
        }
      }.freeze

      SETTINGS = {
        index: {
          number_of_shards: ArchiveConfig.search[:pseud_shards],
          max_result_window: ArchiveConfig.search[:max_results]
        }
      }.freeze
    end
  end
end
