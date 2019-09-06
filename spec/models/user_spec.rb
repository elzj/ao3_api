require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#login' do
    it { should validate_presence_of(:login) }
    it { should validate_length_of(:login).
                  is_at_least(3).
                  is_at_most(40) }
    it { should_not allow_value('!hey').for(:login) }
    it { should_not allow_value('   ').for(:login) }
    it { should_not allow_value('bunnies?').for(:login) }
    it { should allow_value('robot42').for(:login) }
    it { should validate_uniqueness_of(:login).case_insensitive }
  end

  describe '#email' do
    it { should validate_presence_of(:email) }
    # it { should validate_uniqueness_of(:email).case_insensitive }
    it { should_not allow_value('notanemail').for(:email) }
    it { should_not allow_value('notanemail@gmail').for(:email) }
    it { should allow_value('notanemail@gmail.com').for(:email) }
  end

  describe '#password' do
    it { should validate_presence_of(:password) }
    it { should validate_length_of(:password).
                  is_at_least(6).
                  is_at_most(40) }
    it "must be confirmed correctly" do
      user = User.new(password: "foobar", password_confirmation: "barfoo")
      user.valid?
      expect(user.errors[:password_confirmation]).to include("doesn't match Password")
    end
  end
end
