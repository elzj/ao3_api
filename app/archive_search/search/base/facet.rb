# frozen_string_literal: true

module Search
  module Base
    class Facet < Struct.new(:id, :name, :count)
    end
  end
end
