# frozen_string_literal: true

module Search
  module Works
    class Indexer < Search::Base::Indexer
      def klass
        "Work"
      end

      def index_class
        Index
      end

      def document_class
        Document
      end

      def index_all(options = {})
        unless options[:skip_delete]
          Index.delete_index
          Index.create_index(12)
        end
        options[:skip_delete] = true
        super(options)
      end
    end
  end
end
