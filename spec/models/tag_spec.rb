require 'rails_helper'

RSpec.describe Tag, type: :model do
  describe '#name' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).case_insensitive }
    it { should validate_length_of(:name).is_at_most(100) }
    it { should validate_inclusion_of(:type).in_array(Tag::TAGGABLE_TYPES) }
  end
end