require 'rails_helper'

RSpec.describe Chapter, type: :model do
  describe '#title' do
    it { should validate_length_of(:title).is_at_most(255) }
    it "should have extraneous whitespace removed" do
      @chapter = Chapter.new(title: " The Hobbit ")
      @chapter.valid?
      expect(@chapter.title).to eq("The Hobbit")
    end
  end
  describe '#summary' do
    it { should validate_length_of(:summary).is_at_most(1250) }
  end
  describe '#notes' do
    it { should validate_length_of(:notes).is_at_most(5000) }
  end
  describe '#endnotes' do
    it { should validate_length_of(:endnotes).is_at_most(5000) }
  end
end