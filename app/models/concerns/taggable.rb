# frozen_string_literal: true

module Taggable
  extend ActiveSupport::Concern

  included do
    has_many :filter_taggings, as: :filterable
    has_many :filters, through: :filter_taggings
    
    has_many :taggings, as: :taggable
    has_many :tags, through: :taggings
  end

  class_methods do
  end
end
