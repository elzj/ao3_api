require 'rails_helper'

RSpec.describe Profile, type: :model do
  describe '#location' do
    it { should validate_length_of(:location).is_at_most(255) }
  end

  describe '#title' do
    it { should validate_length_of(:title).is_at_most(255) }
  end

  describe '#about_me' do
    it { should validate_length_of(:about_me).is_at_most(2000) }
  end

  describe '#date_of_birth' do
    it "should not be less than 13 years ago" do
      profile = Profile.new(date_of_birth: 12.years.ago)
      expect(profile).not_to be_valid
      expect(profile.errors[:base]).to include("You must be over 13.")
    end
  end
end
