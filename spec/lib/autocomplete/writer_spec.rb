# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Autocomplete::Writer, type: :model, redis: true do
  describe "#add" do
    let(:writer) { Autocomplete::Writer.new("actesting", "39{Tron") }

    it "adds values to a completion set" do
      writer.add
      redis_data = REDIS.zrange("actesting_completion", 0, 100)
      expect(redis_data).to include("t", "tr", "tro", "tron", "tron,,")
    end

    it "adds values to individual token sets" do
      writer.add
      redis_data = REDIS.zrange("actesting_score_tron,,", 0, 100)
      expect(redis_data).to include("39{Tron")
    end
  end

  describe "#remove" do
    let(:writer) { Autocomplete::Writer.new("actesting", "39{Tron") }

    context "when removing the only match for tokens" do
      it "removes all relevant data" do
        writer.add
        writer.remove

        redis_data = REDIS.zrange("actesting_completion", 0, 100)
        expect(redis_data).not_to include("tron,,")

        redis_data = REDIS.zrange("actesting_score_tron,,", 0, 100)
        expect(redis_data).to be_empty
      end
    end

    context "when other values overlap" do
      before do
        Autocomplete::Writer.add("actesting", "99{Tron Legacy")
      end

      it "removes the value but not the completions" do
        writer.add
        writer.remove

        redis_data = REDIS.zrange("actesting_completion", 0, 100)
        expect(redis_data).to include("tro", "tron,,")

        redis_data = REDIS.zrange("actesting_score_tron,,", 0, 100)
        expect(redis_data).to include("99{Tron Legacy")
        expect(redis_data).not_to include("39{Tron")
      end
    end
  end

  describe "#complete_word?" do
    it "is true when the word ends with two commas" do
      writer = Autocomplete::Writer.new("a", "b")
      expect(writer.complete_word?("yo,,")).to be_truthy
    end

    it "is false when the word does not end with two commas" do
      writer = Autocomplete::Writer.new("a", "b")
      expect(writer.complete_word?("y,,o,")).to be_falsey
    end
  end

  describe "#value_string" do
    it "parses the value to get the autocompleting string" do
      writer = Autocomplete::Writer.new("actesting", "77{Star Trek: Enterprise")
      expect(writer.value_string).to eq("Star Trek: Enterprise")
    end
  end

  describe "#words" do
    it "parses the string value into words" do
      writer = Autocomplete::Writer.new("actesting", "77{Star Trek: Enterprise")
      expect(writer.words).to eq(["star", "trek:", "enterprise"])
    end
  end
end
