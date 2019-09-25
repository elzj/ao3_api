# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Search::Sanitizer, type: :model do
  describe '.bool_value' do
    it 'turns strings into boolean values' do
      expect(Search::Sanitizer.bool_value('1')).to be_truthy
      expect(Search::Sanitizer.bool_value('true')).to be_truthy
      expect(Search::Sanitizer.bool_value('T')).to be_truthy
      expect(Search::Sanitizer.bool_value(true)).to be_truthy

      expect(Search::Sanitizer.bool_value('0')).to be_falsey
      expect(Search::Sanitizer.bool_value(nil)).to be_falsey
      expect(Search::Sanitizer.bool_value('nonsense')).to be_falsey
    end
  end

  describe '.sanitize_string' do
    it 'escapes reserved characters' do
      str = "(All) the ~[re-served] char:act+er/s!?"
      sanitized = "\\(All\\) the \\~\\[re\\-served\\] char\\:act\\+er\\/s\\!\\?"
      expect(Search::Sanitizer.sanitize_string(str)).to eq(sanitized)
    end
  end

  describe '.escape_slashes' do
    it 'avoids double-escaping' do
      str = "A/B"
      sanitized = Search::Sanitizer.sanitize_string(
        Search::Sanitizer.sanitize_string(str)
      )
      expect(sanitized).to eq("A\\/B")
    end
  end
end
