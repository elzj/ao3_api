require 'rails_helper'

RSpec.describe Pseud, type: :model do
  it { should validate_length_of(:description).is_at_most(500) }
  it { should allow_value("").for(:description) }

  it { should validate_presence_of(:name) }
  it { should validate_length_of(:name).
                is_at_least(1).
                is_at_most(40) }
  it { should allow_value('1_2-3 Abc').for(:name) }
  it { should_not allow_value('   ').for(:name) }
  it { should_not allow_value('bunnies?').for(:name) }

  subject { Pseud.new(name: "A valid name") }
  it { should validate_uniqueness_of(:name).scoped_to(:user_id).case_insensitive }

  describe '.default' do
    it "asks for records where is_default is true" do
      sql = Pseud.default.to_sql
      expect(sql).to eq("SELECT `pseuds`.* FROM `pseuds` WHERE `pseuds`.`is_default` = TRUE")
    end
  end

  describe '#byline' do
    it "returns the pseud and user name when they're different" do
      user = build(:user, login: "Elizabeth")
      pseud = user.pseuds.build(name: "Liz")
      expect(pseud.byline).to eq("Liz (Elizabeth)")
    end
    it "returns only one name when they're the same" do
      user = build(:user, login: "Hermione")
      pseud = user.pseuds.build(name: "Hermione")
      expect(pseud.byline).to eq("Hermione")
    end
  end
end
