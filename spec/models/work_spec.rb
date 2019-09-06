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
end
