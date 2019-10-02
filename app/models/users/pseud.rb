# frozen_string_literal: true

class Pseud < ApplicationRecord
  include Sanitized

  sanitize_fields description: [:html]

  searchkick mappings: Search::PseudSearch.mappings,
             settings: Search::PseudSearch.settings

  ### ASSOCIATIONS

  belongs_to :user
  has_many :creatorships

  ### VALIDATIONS
  
  validates :name,
            presence: true,
            length: {
              within: ArchiveConfig.pseuds[:name_min]..ArchiveConfig.pseuds[:name_max]
            },
            format: {
              with: /\A[\p{Word} -]+\Z/u,
              message: 'can contain letters, numbers, spaces, underscores, and dashes.'
            },
            uniqueness: {
              scope: :user_id, case_sensitive: false
            }
  # Extra format validation because you can't combine them
  validates :name,
            format: {
              with: /\p{Alnum}/u,
              message: 'must contain at least one letter or number.'
            }
  validates :description,
            length: {
              maximum: ArchiveConfig.pseuds[:description_max],
              allow_blank: true
            }

  ### CALLBACKS

  ### CLASS METHODS
  
  def self.default
    where(is_default: true)
  end

  def self.create_default(user)
    Pseud.create!(user_id: user.id, name: user.login, is_default: true)
  end

  ### INSTANCE METHODS

  delegate :login, to: :user, prefix: true, allow_nil: true
  
  def byline
    login = self.respond_to?(:user_name) ? user_name : user_login
    name == login ? name : "#{name} (#{login})"
  end

  def search_data
    Search::PseudSearch.document(self)
  end
end
