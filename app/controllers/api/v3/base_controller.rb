# frozen_string_literal: true

module Api
  # Version the API explicitly in the URL to allow different versions with breaking changes to co-exist if necessary.
  # The roll over to the next number should happen when code written against the old version will not work
  # with the new version.
  module V3
    class BaseController < ActionController::Base
      # obviously delete later
      def current_user
        User.first
      end
    end
  end
end
