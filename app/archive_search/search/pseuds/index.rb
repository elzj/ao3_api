# frozen_string_literal: true

module Search
  module Pseuds
    # Handles the setup and teardown of an individual index
    class Index < Search::Base::Index
      def klass
        "Pseud"
      end
    end
  end
end
