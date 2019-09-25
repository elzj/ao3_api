# frozen_string_literal: true

module Search
  module Base
    # Handles the setup and teardown of an individual index
    class Index
      def self.klass
        "Example"
      end

      # Include a custom prefix and the current environment
      # to avoid index collision when testing and developing
      # in shared environments.
      # Will be something like "ao3_development_tags"
      def self.name
        [
          ArchiveConfig.search[:prefix],
          Rails.env,
          klass.underscore.pluralize
        ].join("_")
      end

      attr_reader :client

      def initialize(client: nil)
        @client = client || Search::Client.new_client
      end

      def klass
        self.class.klass
      end

      def index_name
        self.class.name
      end

      # Create our index with a few default values
      def create_index(shards: 5)
        client.indices.create(
          index: index_name,
          body: {
            settings: {
              index: {
                # static settings
                number_of_shards: shards,
                # dynamic settings
                max_result_window: ArchiveConfig.search[:max_results]
              }
            }.merge(settings),
            mappings: mapping
          }
        )
      end

      # Delete the index if it exists
      def delete_index
        return unless client.indices.exists(index: index_name)
        client.indices.delete(index: index_name)
      end

      # Used in tests, where the normal refresh process
      # might not execute quickly enough
      def refresh_index
        client.indices.refresh(index: index_name)
      end

      # A single shard for testing gives more realistic
      # ordering of results when working with small amounts of data
      def prepare_for_testing
        return unless Rails.env.test?
        delete_index
        create_index(shards: 1)
      end

      # Note that the index must exist before you can set the mapping
      def update_mapping
        client.indices.put_mapping(
          index: index_name,
          body: mapping
        )
      end

      # Get a hash of mapping data from a file
      def mapping
        load_file_json("#{klass.downcase.pluralize}/mapping.json")
      end

      # Get a hash of settings data from a file
      def settings
        load_file_json("#{klass.downcase.pluralize}/settings.json")
      end

      private

      def load_file_json(filename)
        file = File.join(
          Rails.root,
          "app/archive_search/search",
          filename
        )
        JSON.parse(File.read(file))
      end
    end
  end
end
