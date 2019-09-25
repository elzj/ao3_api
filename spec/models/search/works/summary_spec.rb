# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Search::Works::Summary, type: :model do
  describe "#text" do
    context "with a blank search" do
      it "returns the default sort" do
        summary = summary_for({})
        expect(summary.text).to eq("sort by: best match descending")
      end
    end

    context "with a query" do
      it "begins with the query text" do
        summary = summary_for(query: "sharks lasers")
        expect(summary.text).to eq("sharks lasers" + default_sort)
      end
    end

    context "with a title search" do
      it "adds the title" do
        summary = summary_for(query: "sharks", title: "awesome")
        expect(summary.text).to eq("sharks Title: awesome" + default_sort)
      end
    end

    context "with a creator search" do
      it "adds the creator" do
        summary = summary_for(query: "sharks", creators: "Melville")
        expect(summary.text).to eq("sharks Creator: Melville" + default_sort)
      end
    end

    context "with a tag search" do
      it "should be implemented"
    end

    context "with completeness options" do
      it "includes the complete filter" do
        summary = summary_for(complete: 'T')
        expect(summary.text).to eq("Complete" + default_sort)
      end

      it "includes the incomplete filter" do
        summary = summary_for(complete: 'F')
        expect(summary.text).to eq("Incomplete" + default_sort)
      end
    end

    context "with crossover options" do
      it "includes crossover text" do
        summary = summary_for(crossover: 'T')
        expect(summary.text).to eq("Only Crossovers" + default_sort)
      end

      it "includes the incomplete filter" do
        summary = summary_for(crossover: 'F')
        expect(summary.text).to eq("No Crossovers" + default_sort)
      end
    end

    context "with single chapter options" do
      it "includes the single chapter filter" do
        summary = summary_for(single_chapter: 'T')
        expect(summary.text).to eq("Single Chapter" + default_sort)
      end
    end

    context "with a language search" do
      it "includes the language name" do
        Language.create!(short: 'en', name: 'English')
        summary = summary_for(language_id: 'en')
        expect(summary.text).to eq("Language: English" + default_sort)
      end
    end

    context "with number and date fields" do
      it "includes those fields" do
        summary = summary_for(
          word_count: "<1000",
          kudos_count: ">100",
          revised_at: "< 1 week ago"
        )
        expect(summary.text).to eq(
          "word count: <1000 kudos count: >100 revised at: < 1 week ago" + default_sort
        )
      end
    end

    context "with sort options" do
      it "replaces the default" do
        summary = summary_for(
          sort_column: "authors_to_sort_on",
          sort_direction: "asc"
        )
        expect(summary.text).to eq("sort by: creator ascending")
      end
    end
  end

  def summary_for(options = {})
    Search::Works::Summary.new(
      Search::Works::Form.new(options)
    )
  end

  def default_sort
    " sort by: best match descending"
  end
end
