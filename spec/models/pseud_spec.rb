require 'rails_helper'

RSpec.describe Pseud, type: :model do
  describe '#name' do
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).
                  is_at_least(1).
                  is_at_most(40) }
    it { should allow_value('1_2-3 Abc').for(:name) }
    it { should_not allow_value('   ').for(:name) }
    it { should_not allow_value('bunnies?').for(:name) }

    subject { Pseud.new(name: "A valid name") }
    it { should validate_uniqueness_of(:name).scoped_to(:user_id).case_insensitive }
  end

  describe '#description' do
    it { should validate_length_of(:description).is_at_most(500) }
    it { should allow_value("").for(:description) }
  end
end
