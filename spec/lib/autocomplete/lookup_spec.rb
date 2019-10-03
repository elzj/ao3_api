# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Autocomplete::Lookup, type: :model, redis: true do
  describe "#autocomplete_results" do
    before do
      Autocomplete::Writer.add("actesting", "2{Stargate SG-1", 999)
      Autocomplete::Writer.add("actesting", "1{Star Trek", 1701)
    end

    it "finds matches based on partial data" do
      results = Autocomplete::Lookup.new(
        autocomplete_prefix: "actesting",
        search_param: "star"
      ).autocomplete_results
      expect(results.first).to eq("1{Star Trek")
      expect(results.last).to eq("2{Stargate SG-1")
    end

    it "gets more specific as you add letters" do
      results = Autocomplete::Lookup.new(
        autocomplete_prefix: "actesting",
        search_param: "starg"
      ).autocomplete_results
      expect(results).to eq(["2{Stargate SG-1"])
    end

    it "matches any word" do
      results = Autocomplete::Lookup.new(
        autocomplete_prefix: "actesting",
        search_param: "tre"
      ).autocomplete_results
      expect(results).to eq(["1{Star Trek"])
    end

    it "ranks exact matches higher" do
      Autocomplete::Writer.add("actesting", "4{Star", 2)
      results = Autocomplete::Lookup.new(
        autocomplete_prefix: "actesting",
        search_param: "star"
      ).autocomplete_results
      expect(results.first).to eq("4{Star")
      expect(results.length).to eq(3)
    end

    it "ranks multiple hits higher" do
      Autocomplete::Writer.add("actesting", "5{Start Starkly", 1)
      results = Autocomplete::Lookup.new(
        autocomplete_prefix: "actesting",
        search_param: "star"
      ).autocomplete_results
      expect(results.first).to eq("5{Start Starkly")
      expect(results.length).to eq(3)
    end

    it "caches results for short searches" do
      results = Autocomplete::Lookup.new(
        autocomplete_prefix: "actesting",
        search_param: "st"
      ).autocomplete_results
      expect(results.length).to eq(2)

      Autocomplete::Writer.add("actesting", "3{Star Wars", 77)

      results = Autocomplete::Lookup.new(
        autocomplete_prefix: "actesting",
        search_param: "st"
      ).autocomplete_results
      expect(results.length).to eq(2)

      results = Autocomplete::Lookup.new(
        autocomplete_prefix: "actesting",
        search_param: "sta"
      ).autocomplete_results
      expect(results.length).to eq(3) 
    end
  end
end
