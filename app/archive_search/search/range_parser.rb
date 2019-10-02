# frozen_string_literal: true

module Search
  # Handles user-inputted rangelike data and outputs
  # actual number and date ranges if possible
  class RangeParser
    TIME_REGEX = %r{
      ^(?<operand>[<>]*)\s*
      (?<amount>[\d -]+)\s*
      (?<period>year|week|month|day|hour)s?
      (?<ago>\s*ago)?\s*$
    }xi

    NUMBER_REGEX = %r{
      ^(?<operand>[<>]*)\s*(?<value>[\d,. -]+)\s*$
    }xi

    def self.string_to_range(str)
      new(str).parse
    end

    attr_reader :text_range

    def initialize(text_range)
      @text_range = unescape(text_range.to_s)
    end

    def parse
      if match = text_range.match(TIME_REGEX)
        parse_time(
          operand:  match[:operand],
          amount:   match[:amount],
          period:   match[:period]
        )
      elsif match = text_range.match(NUMBER_REGEX)
        parse_numbers(
          operand: match[:operand],
          value:   match[:value]
        )
      else
        {}
      end
    end

    # Examples: "<1 week ago", "> 6 months ago", "1-3 hours ago"
    def parse_time(operand:, amount:, period:)
      case operand
      when "<"
        { gte: time_from_string(amount, period) }
      when ">"
        { lte: time_from_string(amount, period) }
      when ""
        match = amount.match(/-/)
        if match
          {
            gte: time_from_string(match.pre_match, period),
            lte: time_from_string(match.post_match, period)
          }
        else
          range_from_string(amount, period)
        end
      end
    end

    # This is for form fields where you're asking for items with
    # a certain number of comments, bookmarks, words, etc.
    # Examples: "> 100", "<10", "1,000 - 10,0000"
    def parse_numbers(operand:, value:)
      case operand
      when "<"
        { lte: sanitize_integer(value) }
      when ">"
        { gte: sanitize_integer(value) }
      when ""
        match = value.match(/-/)
        if match
          {
            gte: sanitize_integer(match.pre_match),
            lte: sanitize_integer(match.post_match)
          }
        else
          {
            gte: sanitize_integer(value),
            lte: sanitize_integer(value)
          }
        end
      end
    end

    private

    # helper method to create times from two strings
    def time_from_string(amount, period)
      sanitize_date(amount.to_i.send(period).ago)
    end

    # Generate a range based on one number
    # Interval is based on period used, ie 1 month ago = range from beginning to end of month
    def range_from_string(amount, period)
      amount = amount.to_i
      period = period.singularize

      if %w(year month week day hour).include?(period)
        min = amount.send(period).ago.send("beginning_of_#{period}")
        max = min.send("end_of_#{period}")
      else
        raise "unknown period: " + period
      end

      min, max = [min, max].map { |date| sanitize_date(date) }
      { gte: min, lte: max }
    end

    def unescape(str)
      str.gsub("&gt;", ">").gsub("&lt;", "<").downcase
    end

    # Convert strings with comma/period separators
    def sanitize_integer(number)
      Search::Sanitizer.sanitize_integer(number)
    end

    # Keeping date logic in one place
    def sanitize_date(date)
      Search::Sanitizer.sanitize_date(date)
    end
  end
end
