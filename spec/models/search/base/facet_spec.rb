# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Search::Base::Facet, type: :model do
  it "is a wrapper for simple data" do
    facet = Search::Base::Facet.new(10, "goofy", 16)
    expect(facet.id).to eq(10)
    expect(facet.name).to eq("goofy")
    expect(facet.count).to eq(16)
  end
end
