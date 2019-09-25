require 'rails_helper'

RSpec.describe Freeform, type: :model do
  it 'should exist' do
    expect(Freeform.new(name: "bob")).to be_valid
  end

  describe '#parent_types' do
    it 'should include Fandom' do
      expect(Freeform.new.parent_types).to eq(['Fandom'])
    end
  end  
end
