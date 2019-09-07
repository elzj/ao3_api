require 'rails_helper'

RSpec.describe Relationship, type: :model do
  it 'should exist' do
    expect(Relationship.new(name: "alice/bob")).to be_valid
  end
end
