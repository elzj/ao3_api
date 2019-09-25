module Search
  module Sanitizer
    # Turn string values into truth
    def self.bool_value(value)
      %w[1 T true].include?(value.to_s)
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
