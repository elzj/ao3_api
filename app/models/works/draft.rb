# frozen_string_literal: true

# Draft work class for unposted work management
class Draft < ApplicationRecord
  include Sanitized

  belongs_to :user

  WORK_ATTRIBUTES = %w(
    type
    title
    summary
    notes
    endnotes
    expected_number_of_chapters
    backdate
    restricted
    anon_commenting_disabled
    moderated_commenting_enabled
    language_id
  ).freeze

  TAG_FIELDS = %w(
    ratings
    archive_warnings
    categories
    fandoms
    characters
    relationships
    freeforms
  ).freeze

  FIELDS = WORK_ATTRIBUTES + TAG_FIELDS + %w(
    chapters
    series
    collections
    cocreators
    recipients
    parents
  )

  # Define getter and setter methods for each field that
  # read from and write to the metadata hash
  FIELDS.each do |field|
    define_method field do
      if instance_variable_get("@#{field}").nil?
        instance_variable_set("@#{field}", metadata[field])
      end
      instance_variable_get("@#{field}")
    end

    define_method "#{field}=" do |value|
      instance_variable_set("@#{field}", value)
      self.metadata ||= {}
      self.metadata[field] = value
    end
  end

  # You can't set a database-level default for this field
  # so initialize it here to avoid nils
  # Also, stringify passed in keys to avoid conflicts
  after_initialize do |draft|
    draft.metadata = (draft.metadata || {}).stringify_keys
  end

  before_validation :sanitize_metadata

  ### VALIDATIONS ###

  # Just prevent anything really nutty here
  validates :metadata,
            length: {
              maximum: ArchiveConfig.chapters[:content_max] + 10_000
            }

  ### CLASS METHODS ###
  
  def self.for_user(user)
    order(:updated_at)
    # where(user_id: user.id).order('updated_at DESC')
  end

  ### INSTANCE METHODS ###

  def update_from_params(data)
    self.user_id ||= data.delete(:user_id)
    update_metadata(data)
    save
  end

  def update_metadata(new_data)
    metadata_will_change!
    new_data.each_pair do |key, value|
      send("#{key}=", value) if FIELDS.include?(key.to_s)
    end
    self
  end

  def series_data
    metadata['series'] || {}
  end

  def series_title
    series_data['title']
  end

  def series_position
    series_data['position']
  end

  def work_data
    metadata.slice(*WORK_ATTRIBUTES)
  end

  def chapter_data
    metadata['chapters']
  end

  def tag_data
    TAG_FIELDS.each_with_object({}) do |field, tags|
      tags[field.classify] = metadata[field]
    end
  end

  def creators
    user ? [user.default_pseud_id].compact : []
  end

  def as_json(_options = {})
    json_data = attributes.slice("id", "user_id", "created_at", "updated_at")
    json_data.merge(metadata)
  end

  ### SANITIZE DATA ###

  # This is more complicated than usual because the data is serialized
  def sanitize_metadata
    return unless metadata_changed?
    sanitizers = {
      'title'    => [:html_entities],
      'notes'    => [:html, :css],
      'endnotes' => [:html, :css],
      'summary'  =>  [:html]
    }
    sanitizers.each do |field, sanitizers|
      value = metadata[field]
      next if value.blank?
      self.metadata[field] = sanitized_value(value, sanitizers)
    end
    sanitize_associations
  end

  # Run our embedded associations through the sanitizer
  def sanitize_associations
    sanitize_association('chapters', Chapter.fields_to_sanitize)
    sanitize_association('series', Series.fields_to_sanitize)
  end

  # For each embedded association, sanitize its fields
  def sanitize_association(assoc, sanitizer_info)
    current_data = self.metadata[assoc]
    return unless current_data.is_a?(Array)
    self.metadata[assoc] = current_data.map do |item|
      sanitize_item(item, sanitizer_info)
    end
  end

  def sanitize_item(item, sanitizer_info)
    clean_item = item.dup
    sanitizer_info.each_pair do |field, sanitizers|
      field = field.to_s
      value = clean_item[field]
      clean_item[field] = sanitized_value(value, sanitizers)
    end
    clean_item
  end
end
