# frozen_string_literal: true

module Search
  module Tags
    module Settings
      MAPPINGS = {
        properties: {
          name: {
            type: "text",
            analyzer: "tag_name_analyzer",
            fields: {
              exact: {
                type: "text",
                analyzer: "exact_tag_analyzer"
              },
              keyword: {
                type: "keyword",
                normalizer: "keyword_lowercase"
              }
            }
          },
          tag_type: { type: "keyword" },
          sortable_name: { type: "keyword" },
          uses: { type: "integer" }
        }
      }.freeze

      SETTINGS = {
        index: {
          number_of_shards: ArchiveConfig.search[:tag_shards],
          max_result_window: ArchiveConfig.search[:max_results]
        },
        analysis: {
          analyzer: {
            tag_name_analyzer: {
              type: "custom",
              tokenizer: "standard",
              filter: [
                "lowercase"
              ]
            },
            exact_tag_analyzer: {
              type: "custom",
              tokenizer: "keyword",
              filter: [
                "lowercase"
              ]
            }
          },
          normalizer: {
            keyword_lowercase: {
              type: "custom",
              filter: ["lowercase"]
            }
          }
        }
      }.freeze
    end
  end
end
