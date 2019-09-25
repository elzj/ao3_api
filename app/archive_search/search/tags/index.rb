# frozen_string_literal: true

module Search
  module Tags
    # Handles the setup and teardown of an individual index
    class Index < Search::Base::Index
      def self.klass
        "Tag"
      end
    end
  end
end
