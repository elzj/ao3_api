module Search
  module Sanitizer
    # Turn string values into truth
    def self.bool_value(value)
      %w[1 T true].include?(value.to_s)
    end

    def self.sanitize_integer(num)
      if num.is_a?(String)
        num = num.delete(",.")
      end
      num.to_i
    end

    # Keeps dates within bounds that won't error
    # Removes non-date data from date fields
    def self.sanitize_date(date)
      date = date.to_date
      return date.change(year: 0) if date.year.negative?
      return date.change(year: 9999) if date.year > 9999
      date
    rescue ArgumentError
      nil
    end

    def self.sanitize_string(str)
      escape_slashes(str).gsub('!', '\\!').
                          gsub('+', '\\\\+').
                          gsub('-', '\\-').
                          gsub('?', '\\?').
                          gsub("~", '\\~').
                          gsub("(", '\\(').
                          gsub(")", '\\)').
                          gsub("[", '\\[').
                          gsub("]", '\\]').
                          gsub(':', '\\:')
    end

    # Only escape if it isn't already escaped
    def self.escape_slashes(word)
      word.gsub(/([^\\])\//) { |s| $1 + '\\/' }
    end
  end
end
