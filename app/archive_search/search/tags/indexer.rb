# frozen_string_literal: true

module Search
  module Tags
    class Indexer < Search::Base::Indexer
      def klass
        "Tag"
      end

      def load_file_json(filetype)
        file = File.join(
          File.dirname(__FILE__),
          "#{filetype}.json"
        )
        JSON.parse(File.read(file))
      end

      def document(object)
        Search::Tags::Document.new(object).as_json
      end
    end
  end
end
