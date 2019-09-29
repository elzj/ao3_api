# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable,
         :confirmable,
         :registerable,
         :rememberable,
         :trackable,
         :validatable,
         :lockable,
         :recoverable,
         :jwt_authenticatable,
         jwt_revocation_strategy: JwtBlacklist

  ### ASSOCIATIONS

  has_one :preference
  has_one :profile
  has_many :pseuds
  has_many :creatorships, through: :pseuds

  ### VALIDATIONS

  validates :login,
            presence: true,
            length: {
              within: ArchiveConfig.users[:login_min]..ArchiveConfig.users[:login_max]
            },
            format: {
              with: /\A[A-Za-z0-9]\w*[A-Za-z0-9]\Z/,
              message: "must begin and end with a letter or number; it may also contain underscores but no other characters."
            },
            uniqueness: {
              case_sensitive: false,
              message: "has already been taken"
            }

  ### CALLBACKS

  ### CLASS METHODS

  ### INSTANCE METHODS
  def default_pseud
    pseuds.default.first || Pseud.create_default(self)
  end

  def default_pseud_id
    default_pseud&.id
  end

  def current_profile
    profile || Profile.create_default(self)
  end

  def current_preferences
    preference || Preference.create_default(self)
  end

  # Does this user have a pseud with this id?
  def pseud_with_id?(pseud_id)
    pseuds.where(id: pseud_id).exists?
  end
end
