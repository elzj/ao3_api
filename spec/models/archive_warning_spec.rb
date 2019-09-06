require 'rails_helper'

RSpec.describe ArchiveWarning, type: :model do
  it { should validate_inclusion_of(:name).in_array(ArchiveWarning::DEFAULTS) }

  describe ".sti_name" do
    it "maps class to legacy Warning type" do
      tag = Tag.new(type: "Warning")
      expect(tag).to be_a(ArchiveWarning)

      tag = ArchiveWarning.new
      expect(tag.type).to eq("Warning")
    end
  end
end