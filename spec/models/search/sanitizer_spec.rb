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

  describe '.sanitize_integer' do
    it 'removes separators before converting to integer' do
      expect(Search::Sanitizer.sanitize_integer("525,600")).to eq(525600)
    end
  end

  describe '.sanitize_date' do
    it 'scrubs bad values' do
      sanitized = Search::Sanitizer.sanitize_date("not a date")
      expect(sanitized).to be_nil
    end

    it 'turns a string into a date' do
      date = "1999-01-01".to_date
      sanitized = Search::Sanitizer.sanitize_date("1999-01-01")
      expect(sanitized).to eq(date)
    end

    it 'returns a normal date unchanged' do
      date = "2011-11-11".to_date
      sanitized = Search::Sanitizer.sanitize_date(date)
      expect(sanitized).to eq(date)
    end

    it 'sets a negative date to the year zero' do
      date = "2011-11-11".to_date - 3000.years
      replacement = "0000-11-11".to_date
      sanitized = Search::Sanitizer.sanitize_date(date)
      expect(sanitized).to eq(replacement)
    end

    it 'sets an absurdly large date to the year 9999' do
      date = "2011-11-11".to_date + 30000.years
      replacement = "9999-11-11".to_date
      sanitized = Search::Sanitizer.sanitize_date(date)
      expect(sanitized).to eq(replacement)
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
