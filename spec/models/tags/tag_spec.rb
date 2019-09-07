require 'rails_helper'

RSpec.describe Tag, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_uniqueness_of(:name).case_insensitive }
  it { should validate_length_of(:name).is_at_most(100) }

  it { should validate_inclusion_of(:type).in_array(Tag::TAGGABLE_TYPES) }

  describe ".find_sti_class" do
    it "maps legacy Warning type to class" do
      expect(Tag.find_sti_class("Warning")).to eq(ArchiveWarning)
    end
    it "returns usual result for other tags" do
      expect(Tag.find_sti_class("Category")).to eq(Category)
      expect(Tag.find_sti_class("Freeform")).to eq(Freeform)
    end
  end
end
