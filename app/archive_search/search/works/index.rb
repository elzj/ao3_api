# frozen_string_literal: true

module Search
  module Works
    # Handles the setup and teardown of an individual index
    class Index < Search::Base::Index
      def self.klass
        "Work"
      end
    end
  end
end
