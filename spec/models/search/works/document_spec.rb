# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Search::Works::Document, type: :model do
  describe '#as_json' do
    let(:work) { build(:work) }

    it 'includes whitelisted work attributes' do
      doc_json = Search::Works::Document.new(work).as_json

      sensitive_data = %w(ip_address last_visitor_old)
      expect(doc_json.keys).to include('id', 'title', 'summary')
      expect(doc_json['title']).to eq(work.title)
      expect(doc_json.keys).not_to include(*sensitive_data)
    end
  end

  describe '#collection_data' do
    let(:work) { create(:work) }
    let(:collection) { create(:collection) }

    before do
      work.collection_items.create(
        collection_id: collection.id,
        user_approval_status: 1,
        collection_approval_status: 1
      )
    end

    it "should return collection data" do
      doc = Search::Works::Document.new(work)
      collection_info = {
        id: collection.id,
        name: collection.name,
        title: collection.title
      }
      expect(doc.collection_data[:collections]).to include(collection_info)
    end
  end

  describe '#creator_data' do
    let(:work) { build(:work) }
    let(:pseud) { create(:pseud, name: "Zoe") }
    before do
      work.creatorships.build(pseud_id: pseud.id)
      work.save!
    end

    it 'builds an array of creator data' do
      doc = Search::Works::Document.new(work)
      creator_info = {
        id: pseud.id,
        name: pseud.name,
        user_id: pseud.user_id,
        user_login: pseud.user_login
      }

      expect(doc.creator_data[:creators]).to include(creator_info)
    end

    context 'for an anonymous work' do
      before { work.in_anon_collection = true }

      it 'sets the authors_to_sort_on value to Anonymous' do
        doc = Search::Works::Document.new(work)
        expect(doc.creator_data[:authors_to_sort_on]).to eq("Anonymous")
      end
    end

    context 'with two creators' do
      let(:cocreator) { create(:pseud, name: "abigail") }
      before { work.creatorships.create(pseud_id: cocreator.id) }

      it 'alphabetizes and lower-cases the names' do
        doc = Search::Works::Document.new(work)
        expect(doc.creator_data[:authors_to_sort_on]).to eq("abigail, zoe")
      end      
    end
  end

  describe '#series_data' do
    let(:work) { build(:work) }
    let(:series) { create(:series) }
    before do
      work.series << series
      work.save!
    end

    it 'builds an array of series data' do
      doc = Search::Works::Document.new(work)
      series_info = {
        series: [
          id: series.id,
          title: series.title,
          position: 1
        ]
      }

      expect(doc.series_data).to match(series_info)
    end
  end

  describe '#stats_data' do
    it 'returns a stats hash' do
      work = build(:work)
      stats = {
        'bookmarks_count' => 1,
        'comments_count'  => 2,
        'hit_count'       => 3,
        'kudos_count'     => 4        
      }
      work.stat_counter = StatCounter.new(stats)
      doc = Search::Works::Document.new(work)
      expect(doc.stats_data).to match(stats)
    end
  end

  describe '#tag_data' do
    let(:work)     { create(:work) }
    let(:fandom)   { Fandom.create(name: 'Star Trek', canonical: true) }
    let(:freeform) { Freeform.create(name: 'Canon AU', canonical: true) }
    let(:meta_tag) { Freeform.create(name: 'AU', canonical: true) }

    before do
      work.taggings.create(tagger_id: fandom.id)
      work.filter_taggings.create(filter_id: fandom.id)
      work.filter_taggings.create(filter_id: freeform.id)
      work.filter_taggings.create(filter_id: meta_tag.id, inherited: true)
    end

    it 'returns all relevant tag data' do
      doc = Search::Works::Document.new(work)
      tag_data = {
        tags: [
          { id: fandom.id, name: fandom.name, type: 'Fandom' }
        ],
        meta_tags: [
          { id: meta_tag.id, name: meta_tag.name, type: 'Freeform' }
        ],
        fandoms: [
          { id: fandom.id, name: fandom.name, type: 'Fandom' }
        ],
        freeforms: [
          { id: freeform.id, name: freeform.name, type: 'Freeform' }
        ],
        filter_ids: [fandom.id, freeform.id, meta_tag.id]
      }
      expect(doc.tag_data.with_indifferent_access).to match(tag_data)
    end
  end
end
