require 'rails_helper'

RSpec.describe Search::Tags::Document, type: :model do
  let(:tag) { build_stubbed(:freeform) }
  let(:doc) { Search::Tags::Document.new(tag) }

  describe "#as_json" do
    before do
      synonym = build_stubbed(:freeform, canonical: true, name: "More Official")
      tag.merger_id = synonym.id

      # stub out the methods that talk to the database
      allow(tag).to receive(:has_posted_works?).and_return(true)
      allow(tag).to receive(:parent_ids).and_return([19])
      allow(tag).to receive(:suggested_parent_ids).and_return([6])
    end

    it "includes only whitelisted attributes" do
      data = doc.as_json
      expect(data.keys).to include('id', 'name', 'canonical')
      expect(data.keys).not_to include('last_wrangler_id')
      expect(data['name']).to eq(tag.name)
    end
  end
end
