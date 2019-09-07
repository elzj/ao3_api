require 'rails_helper'

RSpec.describe Chapter, type: :model do
  it { should validate_length_of(:endnotes).is_at_most(5000) }
  it { should validate_length_of(:notes).is_at_most(5000) }
  it { should validate_length_of(:summary).is_at_most(1250) }
  it { should validate_length_of(:title).is_at_most(255) }

  it { is_expected.to callback(:clean_title).before(:validation) }

  describe '#clean_title' do
    it "removes extraneous whitespace" do
      chapter = Chapter.new(title: " The Hobbit ")
      chapter.clean_title
      expect(chapter.title).to eq("The Hobbit")
    end
  end
end
