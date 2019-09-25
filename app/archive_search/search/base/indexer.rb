# frozen_string_literal: true

module Search
  module Base
    # Indexes objects, individually or in batches
    class Indexer
      BATCH_SIZE = 1000
      attr_reader :client

      def initialize(client: nil)
        @client = client || Search::Client.new_client
      end

      # Override in subclasses
      def klass
        "Example"
      end

      def index_class
        Index
      end

      def document_class
        Document
      end

      def index_name
        index_class.name
      end

      # Start from scratch and index all the things
      def full_reindex(skip_delete: false)
        unless skip_delete
          index_class.new(client).delete_index
          index_class.new(client).create_index
        end
        index_from_db
      end

      # Index all the things asynchronously
      def index_from_db
        total = (indexables.count / BATCH_SIZE) + 1
        i = 1
        indexables.find_in_batches(batch_size: BATCH_SIZE) do |group|
          puts "Queueing #{klass} batch #{i} of #{total}"
          AsyncIndexer.new(self, :world).enqueue_ids(group.map(&:id))
          i += 1
        end
      end

      # An ActiveRecord relation for the things we want to index
      # Add conditions here
      def indexables
        Rails.logger.info "Blueshirt: Logging use of constantize class self.indexables #{klass}"
        klass.constantize
      end

      # Should be called after a batch update, with the IDs that were successfully
      # updated. Calls successful_reindex on the indexable class.
      def handle_success(ids)
        return unless indexables.respond_to?(:successful_reindex)
        indexables.successful_reindex(ids)
      end

      # Given a set of ids, return the objects in a hash keyed by id
      def get_records(ids)
        Rails.logger.info "Blueshirt: Logging use of constantize class objects #{klass}"
        klass.constantize.where(id: ids).inject({}) do |h, obj|
          h.merge(obj.id => obj)
        end
      end

      # Originally added to allow IndexSweeper to find the Elasticsearch document
      # ids when they do not match the associated ActiveRecord objects' ids.
      #
      # Override in subclasses if necessary.
      def find_elasticsearch_ids(ids)
        ids
      end

      # Batch index a group of records
      def batch_index_documents(ids)
        client.bulk(body: batch_request_body(ids))
      end

      # Set up a batch request for a group of records
      # If we have an id, but there's no record in the database,
      # we want to delete the item from the search index
      def batch_request_body(ids)
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

      # Synchronously index an object
      def index_document(object)
        info = {
          index:  index_name,
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
          '_id' => id
        }
      end

      # The json document version of the object
      def document(object)
        document_class.new(object).as_json
      end

      # can be overriden by our bookmarkable indexers
      def document_id(id)
        id
      end
    end
  end
end
