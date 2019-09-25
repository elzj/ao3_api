# frozen_string_literal: true

module Search
  module Works
    class Indexer < Search::Base::Indexer
      def klass
        "Work"
      end

      def load_file_json(filetype)
        file = File.join(
          File.dirname(__FILE__),
          "#{filetype}.json"
        )
        JSON.parse(File.read(file))
      end

      def document(object)
        Search::Works::Document.new(object).as_json
      end

      def index_all(options = {})
        unless options[:skip_delete]
          delete_index
          create_index(12)
        end
        options[:skip_delete] = true
        super(options)
      end
    end
  end
end
