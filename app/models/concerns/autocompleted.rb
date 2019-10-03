# frozen_string_literal: true

# Shares validation code between works and work-related models
module Autocompleted
  extend ActiveSupport::Concern

  included do
    after_commit :add_to_autocomplete, on: :create
    after_commit :update_autocomplete, on: :update
    after_commit :remove_from_autocomplete, on: :destroy
  end

  class_methods do
    def autocomplete(options = {})
      options[:autocomplete_prefix] ||= autocomplete_buckets.first
      autocomplete_results(
        Autocomplete::Lookup.new(options).autocomplete_results
      )
    end

    def autocomplete_fields
      [:name]
    end

    def autocomplete_buckets
      ["autocomplete_#{self.to_s.underscore}"]
    end

    # Given values like "1:myname:My Title"
    # return an array of hashes in the form
    # { id: "1", name: "myname", title: "My Title" }
    def autocomplete_results(values)
      separator = ArchiveConfig.autocomplete[:separator]
      keys = [:id] + autocomplete_fields
      values.map { |value| keys.zip(value.split(separator)).to_h }
    end

    # A little string parsing utility
    # to handle comma-separated lists
    def words_from_list(list)
      return [] if list.blank?
      list.split(',').map(&:squish).uniq.select(&:present?)
    end
  end

  def autocomplete_buckets
    self.class.autocomplete_buckets
  end

  def autocomplete_fields
    self.class.autocomplete_fields
  end

  def autocomplete_strings
    autocomplete_fields.map { |field| send(field) }
  end

  def autocomplete_value
    separator = ArchiveConfig.autocomplete[:separator]
    ([id] + autocomplete_strings).join(separator)
  end

  def autocomplete_old_strings
    autocomplete_fields.map do |field|
      attribute_before_last_save(field)
    end
  end

  def autocomplete_old_value
    separator = ArchiveConfig.autocomplete[:separator]
    ([id] + autocomplete_old_strings).join(separator)
  end

  def autocomplete_score
    0 # define via custom value in class
  end

  def autocomplete_fields_changed?
    autocomplete_fields.any? { |field| saved_change_to_attribute?(field) }
  end

  def update_autocomplete
    return unless autocomplete_fields_changed?
    remove_from_autocomplete
    add_to_autocomplete
  end

  def remove_from_autocomplete
    autocomplete_buckets.each do |bucket|
      Autocomplete::Writer.remove(
        bucket, autocomplete_old_value
      )
    end
  end

  def add_to_autocomplete
    autocomplete_buckets.each do |bucket|
      Autocomplete::Writer.add(
        bucket, autocomplete_value, autocomplete_score
      )
    end
  end
end
