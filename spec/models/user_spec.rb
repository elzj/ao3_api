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

  describe '#default_pseud' do
    it 'gets the default pseud if one exists' do
      pseud = create(:pseud)
      user = pseud.user
      expect(user.default_pseud).to eq(pseud)
    end
    it 'creates a default pseud if one does not' do
      user = build_stubbed(:user)
      pseud = user.default_pseud
      expect(pseud).to respond_to(:name)
      expect(pseud.name).to eq(user.login)
      expect(pseud.is_default?).to be_truthy
    end
  end

  describe '#default_pseud_id' do
    it 'returns the default pseud id' do
      pseud = create(:pseud)
      user = pseud.user
      expect(user.default_pseud_id).to eq(pseud.id)
    end
  end

  describe '#current_profile' do
    it 'gets the user profile if one exists' do
      profile = build_stubbed(:profile)
      user = profile.user
      expect(user.current_profile).to eq(profile)
    end
    it 'creates a profile if one does not' do
      user = build_stubbed(:user)
      profile = user.current_profile
      expect(profile).to respond_to(:user_id)
      expect(profile.user_id).to eq(user.id)
    end
  end

  describe '#current_preferences' do
    it 'gets the user preferences if they exists' do
      preference = build_stubbed(:preference)
      user = preference.user
      expect(user.current_preferences).to eq(preference)
    end
    it 'creates preferences if they do not' do
      user = build_stubbed(:user)
      pref = user.current_preferences
      expect(pref).to respond_to(:user_id)
      expect(pref.user_id).to eq(user.id)
    end
  end
end
