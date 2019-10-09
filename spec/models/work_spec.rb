require 'rails_helper'

RSpec.describe Work, type: :model do
  ### VALIDATIONS ###

  it { should validate_length_of(:endnotes).is_at_most(5000) }
  it { should validate_length_of(:notes).is_at_most(5000) }
  it { should validate_length_of(:summary).is_at_most(1250) }
  it { should validate_presence_of(:title) }
  it { should validate_length_of(:title).is_at_most(255) }

  ### CALLBACKS ###

  it { is_expected.to callback(:clean_title).before(:validation) }

  ### INSTANCE METHODS ###

  describe '#clean_title' do
    it "strips surrounding whitespace from titles" do
      work = Work.new(title: "    hello  world    ")
      work.clean_title
      expect(work.title).to eq("hello  world")
    end
    it "does not error when the title is nil" do
      work = Work.new
      work.clean_title
      expect(work.title).to eq("")
    end
  end

  describe "#language_short" do
    it "returns the short value for the language" do
      work = Work.new
      work.language = Language.new(short: 'de')
      expect(work.language_short).to eq('de')
    end

    it "does not error when there is no language" do
      work = Work.new
      expect { work.language_short }.not_to raise_error
    end
  end

  describe "#approved_collections" do
    let(:work) { create(:work) }
    let(:collection) { create(:collection) }

    it "should return approved collections" do
      work.collection_items.create(
        collection_id: collection.id,
        user_approval_status: 0
      )
      expect(work.approved_collections).to be_empty
    end

    it "should not return unapproved collections" do
      work.collection_items.create(
        collection_id: collection.id,
        user_approval_status: 1,
        collection_approval_status: 1
      )
      expect(work.approved_collections).to include(collection)
    end
  end

  describe "#set_completeness" do
    it "sets a work to complete when it is" do
      work = build(:work, chapters_expected: 1, complete: false)
      work.chapters.build(posted: true)
      work.set_completeness
      expect(work.complete).to be_truthy
    end

    it "sets a work to incomplete when it is" do
      work = build(:work, chapters_expected: 1, complete: false)
      work.chapters.build(posted: true)
      work.set_completeness
      expect(work.complete).to be_truthy

      work.chapters_expected = 2
      work.chapters.build(posted: false)
      work.set_completeness
      expect(work.complete).to be_falsey
    end
  end

  describe "#set_word_count" do
    it "sets the word count based on posted chapter data" do
      work = build_stubbed(:work)
      work.chapters.build(posted: true, word_count: 20)
      work.chapters.build(posted: false, word_count: 30)
      work.set_word_count
      expect(work.word_count).to eq(20)
    end
  end
end
