require 'rails_helper'

RSpec.describe Preference, type: :model do
  describe '#work_title_format' do
    it { should allow_value('bunnies, bunnies').for(:work_title_format) }
    it { should_not allow_value('bunnies?').for(:work_title_format) }
  end
end
