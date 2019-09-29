# frozen_string_literal: true

# Internal bookmarks, which may be works, series, or external works
class Bookmark < ApplicationRecord
  include Collectible
  include Sanitized
  include Taggable

  sanitize_fields bookmarker_notes: [:html]

  belongs_to :bookmarkable, polymorphic: true
  belongs_to :pseud

  validates :bookmarker_notes,
            length: {
              maximum: ArchiveConfig.bookmarks[:notes_max]
            }

  ### CLASS METHODS ###

  def self.visible_to(user)
    where(private: false).or(
      where(pseud_id: user.pseuds.pluck(:id))
    )
  end

  ### INSTANCE METHODS ###

  def bookmarkable_date
    bookmarkable&.sortable_date
  end

  # Given a current user, try to save this bookmark to their account
  def save_for_user(user)
    validate_ownership(user) &&
      assign_to_user(user) && save
  end

  # Prevent creation of bookmarks under other users' accounts
  def validate_ownership(user)
    return true if pseud_id.nil? || user.pseud_with_id?(pseud_id)
    errors.add(:pseud_id, :blank, message: "must belong to your account")
    false
  end

  # If a user is logged in but doesn't provide a pseud id,
  # create the bookmark under their default pseud
  def assign_to_user(user)
    self.pseud_id ||= user.default_pseud_id
  end
end
