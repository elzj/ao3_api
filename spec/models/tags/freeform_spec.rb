require 'rails_helper'

RSpec.describe Freeform, type: :model do
  it 'should exist' do
    expect(Freeform.new(name: "bob")).to be_valid
  end
end
