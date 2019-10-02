# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Search::RangeParser, type: :model do
  describe '.string_to_range' do
    context 'when given non-range data' do
      it 'returns an empty hash' do
        range = Search::RangeParser.string_to_range("hello world")
        expect(range).to eq({})

        range = Search::RangeParser.string_to_range(nil)
        expect(range).to eq({})
      end
    end

    context 'when given a date range' do
      it 'returns a max value with greater than' do
        str = '> 6 months ago'
        date = 6.months.ago.to_date
        range = Search::RangeParser.string_to_range(str)
        expect(range).to match(lte: date)
      end

      it 'ignores capitalization' do
        str = '> 6 MONTHS'
        date = 6.months.ago.to_date
        range = Search::RangeParser.string_to_range(str)
        expect(range).to match(lte: date)
      end

      it 'returns a min value with less than' do
        str = '<1 week ago'
        date = 1.week.ago.to_date
        range = Search::RangeParser.string_to_range(str)
        expect(range).to match(gte: date)
      end

      it 'returns a range with a dash' do
        str = '3-4 days ago'
        min_date = 3.days.ago.to_date
        max_date = 4.days.ago.to_date
        range = Search::RangeParser.string_to_range(str)
        expect(range).to match(gte: min_date, lte: max_date)
      end
    end

    context 'when given a number range' do
      it 'returns a min value with greater than' do
        str = ">10"
        range = Search::RangeParser.string_to_range(str)
        expect(range).to match(gte: 10)
      end

      it 'returns a max value with less than' do
        str = "< 99"
        range = Search::RangeParser.string_to_range(str)
        expect(range).to match(lte: 99)
      end

      it 'returns a range with a dash' do
        str = "1000-8000"
        range = Search::RangeParser.string_to_range(str)
        expect(range).to match(gte: 1000, lte: 8000)
      end

      it 'ignores whitespace' do
        str = "6  -  66"
        range = Search::RangeParser.string_to_range(str)
        expect(range).to match(gte: 6, lte: 66)
      end

      it 'ignores commas' do
        str = "1,000 - 10,000"
        range = Search::RangeParser.string_to_range(str)
        expect(range).to match(gte: 1000, lte: 10000)
      end
    end
  end
end
