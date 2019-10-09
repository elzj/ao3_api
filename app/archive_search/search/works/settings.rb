# frozen_string_literal: true

module Search
  module Works
    module Settings
      MAPPINGS = {
        properties: {
          title: {
            type: "text",
            analyzer: "simple"
          },
          series: {
            type: "object"
          },
          authors_to_sort_on: {
            type: "keyword"
          },
          title_to_sort_on: {
            type: "keyword"
          },
          imported_from_url: {
            type: "keyword"
          },
          work_types: {
            type: "keyword"
          },
          posted: { type: "boolean" },
          restricted: { type: "boolean" },
          hidden_by_admin: { type: "boolean" },
          complete: { type: "boolean" },
          anonymous: { type: "boolean" },
          unrevealed: { type: "boolean" },
          created_at: { type: "date" },
          updated_at: { type: "date" },
          revised_at: { type: "date" }
        }
      }.freeze

      SETTINGS = {
        index: {
          number_of_shards: ArchiveConfig.search[:work_shards],
          max_result_window: ArchiveConfig.search[:max_results]
        }
      }.freeze
    end
  end
end
