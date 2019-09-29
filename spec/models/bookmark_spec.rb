require 'rails_helper'

RSpec.describe Bookmark, type: :model do
  it { should validate_length_of(:bookmarker_notes).is_at_most(5000) }
end
