# frozen_string_literal: true

module Api
  # Version the API explicitly in the URL to allow different versions with breaking changes to co-exist if necessary.
  # The roll over to the next number should happen when code written against the old version will not work
  # with the new version.
  module V3
    class BaseController < ActionController::Base
      skip_before_action :verify_authenticity_token
    end
  end
end
