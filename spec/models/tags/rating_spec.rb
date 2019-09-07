require 'rails_helper'

RSpec.describe Rating, type: :model do
  it { should validate_inclusion_of(:name).in_array(Rating::DEFAULTS) }
end
