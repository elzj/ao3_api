require 'rails_helper'

RSpec.describe Character, type: :model do
  it 'should exist' do
    expect(Character.new(name: "bob")).to be_valid
  end

  describe '#parent_types' do
    it 'should include Fandom' do
      expect(Character.new.parent_types).to eq(['Fandom'])
    end
  end
end
