require 'rails_helper'

RSpec.describe MetaTagging, type: :model do
  describe 'associations' do
    it { should belong_to(:sub_tag) }
    it { should belong_to(:meta_tag) }
  end
end
