# frozen_string_literal: true

class Profile < ApplicationRecord
  include Sanitized

  sanitize_fields about_me: [:html]

  ### ASSOCIATIONS
  belongs_to :user
  
  ### VALIDATIONS
  validates :location,
            length: {
              allow_blank: true,
              maximum: ArchiveConfig.profiles[:location_max]
            }
  validates :title,
            length: {
              allow_blank: true,
              maximum: ArchiveConfig.profiles[:title_max]
            }
  validates :about_me,
            length: {
              allow_blank: true,
              maximum: ArchiveConfig.profiles[:about_me_max]
            }

  validate :no_kids_allowed

  # Checks date of birth when user updates profile
  # blank is okay as they already checked that they were over 13 when registering
  def no_kids_allowed
    return unless date_of_birth.present?
    if date_of_birth > 13.years.ago.to_date
      errors.add(:base, 'You must be over 13.')
    end
  end

  ### CALLBACKS

  ### CLASS METHODS
  def self.create_default(user)
    create!(user_id: user.id)
  end

  ### INSTANCE METHODS
end
