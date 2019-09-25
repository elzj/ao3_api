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
end
