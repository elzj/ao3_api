require 'rails_helper'

RSpec.describe Fandom, type: :model do
  it 'should exist' do
    expect(Fandom.new(name: "bob")).to be_valid
  end
end
