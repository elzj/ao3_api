require 'rails_helper'

RSpec.describe SerialWork, type: :model do
  context 'associations' do
    it { should belong_to(:series) }
    it { should belong_to(:work) }
  end
end
