# frozen_string_literal: true

module Search
  module Shared
    # Shares code among document classes for models in collections
    module CollectibleDocument
      # Returns a hash with an array of this record's collection data
      def collection_data
        info = record.approved_collections.pluck_as_hash(:id, :name, :title)
        { collections: info }
      end
    end
  end
end
