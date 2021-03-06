# frozen_string_literal: true

# For JSON web token revokation
class JwtBlacklist < ApplicationRecord
  include Devise::JWT::RevocationStrategies::Denylist

  self.table_name = 'jwt_blacklist'
end
