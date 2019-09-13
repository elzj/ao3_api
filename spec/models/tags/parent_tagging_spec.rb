require 'rails_helper'

RSpec.describe ParentTagging, type: :model do
  describe 'associations' do
    it { should belong_to(:parent_tag) }
    it { should belong_to(:child_tag) }
  end
end
