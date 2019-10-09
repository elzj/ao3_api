# encoding=utf-8

require 'nokogiri'

module Otw
  class WordCounter
    # List of Unicode scripts where spaces are not used as separators,
    # and character counts should be used for word counts.
    # Check if a script is supported by the version of Ruby we use:
    # https://ruby-doc.org/core/Regexp.html#class-Regexp-label-Character+Properties
    CHARACTER_COUNT_SCRIPTS = %w(Han Hiragana Katakana Thai).freeze

    attr_accessor :text

    def initialize(text)
      @text = text
    end

    # only count actual text
    # scan by word boundaries after stripping hyphens and apostrophes
    # so one-word and one's will be counted as one word, not two.
    # -- is replaced by — (emdash) before strip so one--two will count as 2
    def count
      count = 0
      # avoid blank? so we don't need to load Rails for tests
      return count if @text.nil? || @text.empty?

      body = Nokogiri::HTML(@text).xpath('//body').first
      body.traverse { |node| count += count_for_node(node) }
      count
    end

    # Scripts such as Chinese and Japanese that do not have space between words
    # are counted based on the number of characters. If a text include mixed
    # languages, only characters in these languages would be counted as words,
    # words in other languages are counted as usual
    def count_for_node(node)
      return 0 unless node.is_a? Nokogiri::XML::Text
      node.inner_text.gsub(/--/, "—").gsub(/['’‘-]/, "").scan(script_regex).size
    end

    def script_regex
      scripts = CHARACTER_COUNT_SCRIPTS.map { |lang| "\\p{#{lang}}" }.join("|")
      /[#{scripts}]|((?!#{scripts})[[:word:]])+/
    end
  end
end
