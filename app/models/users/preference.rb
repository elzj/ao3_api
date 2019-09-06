# frozen_string_literal: true

class Preference < ApplicationRecord
  ### ASSOCIATIONS
  belongs_to :user

  ### VALIDATIONS
  validates :work_title_format,
            format: {
              with: /^[a-zA-Z0-9_\-,\. ]+$/,
              message: "can only contain letters, numbers, spaces, and some limited punctuation (comma, period, dash, underscore).",
              multiline: true
            }


  ### CALLBACKS

  ### CLASS METHODS
  def self.create_default(user)
    create(
      user_id: user.id,
      preferred_locale: ArchiveConfig.locales[:default_id]
    )
  end

  ### INSTANCE METHODS  
end
