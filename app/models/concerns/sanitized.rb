# frozen_string_literal: true

# Sanitizes fields that accept html
# Call on a class like so:
# class Foo
#   include Sanitized
#   sanitize_fields notes: [:html]
# end
#
# Current sanitizer values: :html, :css, :multimedia
module Sanitized
  extend ActiveSupport::Concern

  included do
    before_validation :clean_html_fields
  end

  class_methods do
    def sanitize_fields(opts = {})
      @fields_to_sanitize = opts
    end

    def fields_to_sanitize
      @fields_to_sanitize
    end
  end

  # Our hash of sanitizing data
  def fields_to_sanitize
    self.class.fields_to_sanitize || {}
  end

  # Given the sanitize data set in the model,
  # sanitize each field and update the value
  def clean_html_fields
    fields_to_sanitize.each_pair do |field, sanitizers|
      next unless changes.key?(field)
      value = send(field)
      next if value.blank? || sanitizers.blank?
      send("#{field}=", sanitized_value(value, sanitizers))
    end
  end

  # Given a string and an array of sanitize options,
  # return sanitized text
  def sanitized_value(value, sanitizers)
    Otw::Sanitizer.sanitize(value, sanitizers)
  end
end
