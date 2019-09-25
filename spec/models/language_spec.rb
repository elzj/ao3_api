require 'rails_helper'

RSpec.describe Language, type: :model do
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:short) }
  it { should validate_uniqueness_of(:short).case_insensitive }
  it { should validate_presence_of(:sortable_name) }

  ### CALLBACKS ###
  
  it { is_expected.to callback(:set_sortable_name).before(:validation) }

  describe '#set_sortable_name' do
    it 'sets the sortable name equal to the short if blank' do
      lang = Language.new(short: 'ZZ')
      lang.set_sortable_name
      expect(lang.sortable_name).to eq('zz')
    end

    it 'does not override the existing value if not blank' do
      lang = Language.new(short: 'zz', sortable_name: 'aa')
      lang.set_sortable_name
      expect(lang.sortable_name).to eq('aa')
    end
  end
end
