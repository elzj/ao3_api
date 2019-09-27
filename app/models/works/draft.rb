# frozen_string_literal: true

# Draft work class for unposted work management
class Draft < ApplicationRecord
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
    chapter
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
  after_initialize do |draft|
    draft.metadata ||= {}
  end

  ### VALIDATIONS ###

  # Just prevent anything really nutty here
  validates :metadata,
            length: {
              maximum: ArchiveConfig.chapters[:content_max] + 10_000
            }

  ### CLASS METHODS ###
  
  def self.for_user(user)
    where(user_id: user.id).order('updated_at DESC')
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
    metadata['chapter']
  end

  def tag_data
    TAG_FIELDS.each_with_object({}) do |field, tags|
      tags[field.classify] = metadata[field]
    end
  end

  def creators
    user ? [user.default_pseud_id].compact : []
  end
end
