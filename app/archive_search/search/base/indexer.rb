# frozen_string_literal: true

module Search
  module Base
    class Indexer
      BATCH_SIZE = 1000
      attr_reader :client

      def initialize(client: nil)
        @client = client || Search::Client.new_client
      end

      def klass
        "generic"
      end

      # Originally added to allow IndexSweeper to find the Elasticsearch document
      # ids when they do not match the associated ActiveRecord objects' ids.
      #
      # Override in subclasses if necessary.
      def find_elasticsearch_ids(ids)
        ids
      end

      def delete_index
        return unless client.indices.exists(index: index_name)
        client.indices.delete(index: index_name)
      end

      def refresh_index
        client.indices.refresh(index: index_name)
      end

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

      def prepare_for_testing
        return unless Rails.env.test?
        delete_index
        create_index(shards: 1)
      end

      # Note that the index must exist before you can set the mapping
      def create_mapping
        client.indices.put_mapping(
          index: index_name,
          type: document_type,
          body: mapping
        )
      end

      def mapping
        load_file_json("mapping")
      end

      def settings
        load_file_json("settings")
      end

      def load_file_json(filetype)
        file = File.join(
          File.dirname(__FILE__),
          "#{filetype}.json"
        )
        JSON.parse(File.read(file))
      end
      
      def index_all(skip_delete: false)
        unless skip_delete
          delete_index
          create_index
        end
        index_from_db
      end

      def index_from_db
        total = (indexables.count / BATCH_SIZE) + 1
        i = 1
        indexables.find_in_batches(batch_size: BATCH_SIZE) do |group|
          puts "Queueing #{klass} batch #{i} of #{total}"
          AsyncIndexer.new(self, :world).enqueue_ids(group.map(&:id))
          i += 1
        end
      end

      # Add conditions here
      def indexables
        Rails.logger.info "Blueshirt: Logging use of constantize class self.indexables #{klass}"
        klass.constantize
      end

      def index_name
        [
          ArchiveConfig.search[:prefix],
          Rails.env,
          klass.underscore.pluralize
        ].join("_")
      end

      def document_type
        klass.underscore
      end

      # Should be called after a batch update, with the IDs that were successfully
      # updated. Calls successful_reindex on the indexable class.
      def handle_success(ids)
        return unless indexables.respond_to?(:successful_reindex)
        indexables.successful_reindex(ids)
      end

      def get_records(ids)
        Rails.logger.info "Blueshirt: Logging use of constantize class objects #{klass}"
        klass.constantize.where(id: ids).inject({}) do |h, obj|
          h.merge(obj.id => obj)
        end
      end

      def batch(ids)
        @batch = []
        objects = get_records(ids)
        ids.each do |id|
          object = objects[id.to_i]
          if object.present?
            @batch << { index: routing_info(id) }
            @batch << document(object)
          else
            @batch << { delete: routing_info(id) }
          end
        end
        @batch
      end

      def index_documents
        client.bulk(body: batch)
      end

      def index_document(object)
        info = {
          index:  index_name,
          type:   document_type,
          id:     document_id(object.id),
          body:   document(object)
        }
        if respond_to?(:parent_id)
          info[:routing] = parent_id(object.id, object)
        end
        client.index(info)
      end

      def routing_info(id)
        {
          '_index' => index_name,
          '_type' => document_type,
          '_id' => id
        }
      end

      def document(object)
        object.as_json(root: false)
      end

      # can be overriden by our bookmarkable indexers
      def document_id(id)
        id
      end
    end
  end
end
