# frozen_string_literal: true

module Autocomplete
  # Tokenizes strings
  class Tokenizer
    def initialize(str)
      @str = str
    end

    # Loop through and build a token array of words and fragments
    # For 'the', you'd get ['the,,', 'the', 'th', 't']
    def tokens
      words.each_with_object([]) do |word, tokens|
        tokens << word + word_terminator
        word.length.downto(1).each do |last_index|
          tokens << word.slice(0, last_index)
        end
      end
    end

    # split on one or more spaces, ampersand, slash, double
    # quotation mark, opening parenthesis, closing parenthesis
    # (just in case), tilde, hyphen
    def words
      splitter_regex = %r{(?:\s+|\&|\/|"|\(|\)|\~|-)}
      @str.downcase.split(splitter_regex).reject(&:empty?)
    end

    # Return the complete word values with terminators
    # and include the last word unless we have multiple words
    # and it's only one character long
    def words_with_terminator
      last_word = words.last
      terms = words[0..-2].map { |w| w + word_terminator }
      terms << last_word if terms.length == 1 || last_word.length > 1
      terms
    end

    # Set to ',,'
    def word_terminator
      ArchiveConfig.autocomplete[:terminator]
    end
  end
end
