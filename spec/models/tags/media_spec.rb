require 'rails_helper'

RSpec.describe Media, type: :model do
  it 'should exist' do
    expect(Media.new(name: "Movies")).to be_valid
  end
end
