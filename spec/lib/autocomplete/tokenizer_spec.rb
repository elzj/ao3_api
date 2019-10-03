# frozen_string_literal: true

require 'spec_helper'
require_relative '../../../lib/autocomplete/tokenizer'

RSpec.describe Autocomplete::Tokenizer do
  describe "#tokens" do
    it "returns an array of tokens for a single word" do
      tokenizer = Autocomplete::Tokenizer.new("hello")
      tokens = %w(
        hello,, hello hell hel he h
      )
      expect(tokenizer.tokens).to eq(tokens)
    end

    it "tokenizes multiple words" do
      tokenizer = Autocomplete::Tokenizer.new("Star Wars")
      tokens = %w(
        star,, star sta st s
        wars,, wars war wa w
      )
      expect(tokenizer.tokens).to eq(tokens)
    end
  end
end
