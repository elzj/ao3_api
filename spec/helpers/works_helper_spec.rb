require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the WorksHelper. For example:
#
# describe WorksHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe WorksHelper, type: :helper do
  describe "tag_facet_keys" do
    it "returns an array of plural tag types, in order" do
      headings = %w(ratings archive_warnings categories fandoms characters relationships freeforms)
      expect(helper.tag_facet_keys).to eq(headings)
    end
  end

  describe "filter_group_div" do
    it "omits the show class by default" do
      search = double('Search')
      facet = double('Facet', field: "rating_ids")
      facets = { 'ratings' => [facet] }

      html = "<div class=\"filter collapse\" id=\"collapse-ratings\">yo</div>"

      expect(search).to receive(:rating_ids).and_return(false)
      expect(helper.filter_group_div(search, facets, 'ratings') { "yo" }).to match(html)
    end

    it "includes the show class when a value is selected" do
      search = double('Search')
      facet = double('Facet', field: "rating_ids")
      facets = { 'ratings' => [facet] }

      html = "<div class=\"filter collapse show\" id=\"collapse-ratings\">yo</div>"

      expect(search).to receive(:rating_ids).and_return(true)
      expect(helper.filter_group_div(search, facets, 'ratings') { "yo" }).to match(html)
    end
  end
end
