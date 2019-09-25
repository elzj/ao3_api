require 'rails_helper'

RSpec.describe Relationship, type: :model do
  it 'should exist' do
    expect(Relationship.new(name: "alice/bob")).to be_valid
  end

  describe '#parent_types' do
    it 'should include Fandom and Character' do
      expect(Relationship.new.parent_types).to eq(%w(Fandom Character))
    end
  end
end
