require 'rails_helper'

RSpec.describe Tag, type: :model do
  # VALIDATIONS
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name).case_insensitive }
  it { should validate_length_of(:name).is_at_most(100) }
  it { should validate_inclusion_of(:type).in_array(Tag::TAGGABLE_TYPES) }

  # CALLBACKS
  it { is_expected.to callback(:squish_name).before(:validation) }
  it { is_expected.to callback(:set_sortable_name).before(:validation) }

  ### CLASS METHODS ###

  describe ".by_type" do
    it "returns tags of a particular type" do
      Fandom.create(name: "Star Trek")
      Character.create(name: "Spock")

      results = Tag.by_type("Character")
      expect(results.length).to eq(1)
      expect(results.first.name).to eq("Spock")
    end
  end

  describe ".find_sti_class" do
    it "maps legacy Warning type to class" do
      expect(Tag.find_sti_class("Warning")).to eq(ArchiveWarning)
    end
    it "returns usual result for other tags" do
      expect(Tag.find_sti_class("Category")).to eq(Category)
      expect(Tag.find_sti_class("Freeform")).to eq(Freeform)
    end
  end

  ### INSTANCE METHODS ###

  describe "#has_posted_works?" do
    let(:tag) { create(:freeform) }

    context "for a tag with no works" do
      it "returns false" do
        expect(tag.has_posted_works?).to be_falsey
      end
    end

    context "for a tag with an unposted work" do
      before do
        work = create(:work, posted: false)
        work.taggings.create(tagger_id: tag.id)
      end

      it "returns false" do
        expect(tag.has_posted_works?).to be_falsey
      end
    end

    context "for a tag with a posted work" do
      before do
        work = create(:work, posted: true)
        work.taggings.create(tagger_id: tag.id)
      end

      it "returns true" do
        expect(tag.has_posted_works?).to be_truthy
      end
    end    
  end

  describe "#parent_ids" do
    it "returns an array of parent tag ids of a particular type" do
      ship = Relationship.create(name: "Elizabeth/Darcy")
      character = Character.create(name: "Eliabeth Bennet")
      fandom = Fandom.create(name: "Pride and Prejudice")
      ship.parent_taggings.create(filterable_id: character.id)
      ship.parent_taggings.create(filterable_id: fandom.id)

      expect(ship.parent_ids("Character")).to eq([character.id])
    end
  end

  describe "#parent_types" do
    it "is empty by default" do
      expect(Tag.new.parent_types).to be_empty
    end
  end

  describe "#set_sortable_name" do
    it "sets the sortable name field to an article-less value" do
      tag = Tag.new(name: "The Great Escape")
      tag.set_sortable_name
      expect(tag.sortable_name).to eq("Great Escape")
    end
  end

  describe "#squish_name" do
    it "removes extra whitespace from name" do
      tag = Tag.new(name: "   roomy   ")
      tag.squish_name
      expect(tag.name).to eq("roomy")
    end
  end

  describe "#suggested_parent_ids" do
    it "returns tags used on the same works"
  end

  describe "#syn" do
    let(:tag) { build(:freeform, merger_id: nil) }

    context "for a tag with no merger_id" do
      it "returns nil" do
        expect(tag.syn).to be_nil
      end
    end

    context "for a tag with a merger_id" do
      let(:official) { create(:freeform, canonical: true) }

      it "returns the tag's official synonym" do
        tag.merger_id = official.id
        expect(tag.syn).to eq(official)
      end
    end
  end

  describe "#syns" do
    let(:tag) { build_stubbed(:freeform) }

    context "for a tag with no synonyms" do
      it "returns an empty array" do
        expect(tag.syns).to be_empty
      end
    end

    context "for a tag with synonyms" do
      let(:syn) { create(:freeform, merger_id: tag.id) }

      it "returns the tag's synonyms" do
        expect(tag.syns).to eq([syn])
      end
    end
  end

  describe "#uses" do
    it "returns the taggings count cache" do
      tag = Tag.new(taggings_count_cache: 86)
      expect(tag.uses).to eq(86)
    end
  end
end
