require 'rails_helper'

RSpec.describe SearchHelper, type: :model do
  describe '.standardize_boolean' do
    it 'turns strings into boolean values' do
      expect(SearchHelper.standardize_boolean('1')).to be_truthy
      expect(SearchHelper.standardize_boolean('true')).to be_truthy
      expect(SearchHelper.standardize_boolean('T')).to be_truthy
      expect(SearchHelper.standardize_boolean(true)).to be_truthy

      expect(SearchHelper.standardize_boolean('0')).to be_falsey
      expect(SearchHelper.standardize_boolean(nil)).to be_falsey
      expect(SearchHelper.standardize_boolean('nonsense')).to be_falsey
    end
  end
  describe '.sanitize_string' do
    it 'escapes reserved characters' do
      str = "(All) the ~[re-served] char:act+er/s!?"
      sanitized = "\\(All\\) the \\~\\[re\\-served\\] char\\:act\\+er\\/s\\!\\?"
      expect(SearchHelper.sanitize_string(str)).to eq(sanitized)
    end
  end
  describe '.escape_slashes' do
    it 'avoids double-escaping' do
      str = "A/B"
      sanitized = SearchHelper.sanitize_string(SearchHelper.sanitize_string(str))
      expect(sanitized).to eq("A\\/B")
    end
  end
  describe '.index_name' do
    it 'constructs an index name based on a record type' do
      name = SearchHelper.index_name("frogs")
      expect(name).to eq("ao3api_test_frogs")
    end
  end
end
