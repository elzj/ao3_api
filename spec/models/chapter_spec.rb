require 'rails_helper'

RSpec.describe Chapter, type: :model do
  it { should validate_length_of(:endnotes).is_at_most(5000) }
  it { should validate_length_of(:notes).is_at_most(5000) }
  it { should validate_length_of(:summary).is_at_most(1250) }
  it { should validate_length_of(:title).is_at_most(255) }

  it { is_expected.to callback(:clean_title).before(:validation) }
  it { is_expected.to callback(:count_words).before(:validation) }

  describe '#clean_title' do
    it "removes extraneous whitespace" do
      chapter = Chapter.new(title: " The Hobbit ")
      chapter.clean_title
      expect(chapter.title).to eq("The Hobbit")
    end
  end

  # The word counter spec tests the specific counting scenarios
  describe '#count_words' do
    it "sets the word count" do
      chapter = Chapter.new(content: "one two three")
      chapter.count_words
      expect(chapter.word_count).to eq(3)
    end
  end

  describe '.update_positions' do
    it "repositions chapters, giving precedence to new updates" do
      work = create(:work)
      ch1 = create(:chapter, work_id: work.id, position: 1, updated_at: 2.hours.ago)
      ch2 = create(:chapter, work_id: work.id, position: 2)
      new_ch1 = create(:chapter, work_id: work.id, position: 1)
      Chapter.update_positions(work_id: work.id)

      expect(Chapter.in_order).to eq([new_ch1, ch1, ch2])
      expect(ch1.reload.position).to eq(2)
      expect(ch2.reload.position).to eq(3)
    end
  end
end
