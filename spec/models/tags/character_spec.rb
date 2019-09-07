require 'rails_helper'

RSpec.describe Character, type: :model do
  it 'should exist' do
    expect(Character.new(name: "bob")).to be_valid
  end
end
