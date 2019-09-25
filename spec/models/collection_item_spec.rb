# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CollectionItem, type: :model do
  context 'associations' do
    it { should belong_to(:collection) }
    it { should belong_to(:item) }
  end
end
