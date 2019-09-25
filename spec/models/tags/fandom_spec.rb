require 'rails_helper'

RSpec.describe Fandom, type: :model do
  it 'should exist' do
    expect(Fandom.new(name: "bob")).to be_valid
  end

  describe '#parent_types' do
    it 'should include Media' do
      expect(Fandom.new.parent_types).to eq(['Media'])
    end
  end
end
