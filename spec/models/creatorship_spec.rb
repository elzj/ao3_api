require 'rails_helper'

RSpec.describe Creatorship, type: :model do
  context 'associations' do
    it { should belong_to(:pseud) }
    it { should belong_to(:creation) }
  end
end
