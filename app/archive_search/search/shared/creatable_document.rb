# frozen_string_literal: true

module Search
  module Shared
    # Shares code among document classes for models with creatorships
    module CreatableDocument
      def creator_data
        data = pseuds.map do |pseud|
          {
            id: pseud.id,
            name: pseud.name,
            user_id: pseud.user_id,
            user_login: pseud.user_login
          }
        end
        {
          authors_to_sort_on: sorted_byline,
          creators: data
        }
      end

      def sorted_byline
        scrubber = %r{^[\+\-=_\?!'"\.\/]}
        if record.respond_to?(:anonymous?) && record.anonymous?
          "Anonymous"
        else
          pseuds.map { |pseud| pseud.name.downcase }.
            sort.join(", ").downcase.gsub(scrubber, '')
        end
      end

      def pseuds
        @pseuds ||= record.pseuds.includes(:user)
      end
    end
  end
end
