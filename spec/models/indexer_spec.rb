require 'rails_helper'

RSpec.describe Indexer, type: :model do
  context 'indices' do
    let(:fake_client) do
      fake_client = double("search client")
      fake_client.stub(:exists).and_return(true)
      fake_client.stub(:indices).and_return(fake_client)
      fake_client
    end

    describe '#delete_index' do
      it "tries to delete the index" do
        fake_client.stub(:delete).and_return(true)
        expect(fake_client).to receive(:delete)
        indexer = Indexer.new(fake_client)
        indexer.delete_index
      end
    end

    describe '#create_index' do
      it "creates the index" do
        fake_client.stub(:create).and_return(true)
        expect(fake_client).to receive(:create)
        indexer = Indexer.new(fake_client)
        indexer.create_index
      end
    end

    describe '#refresh_index' do
      it "refreshes the index" do
        fake_client.stub(:refresh).and_return(true)
        expect(fake_client).to receive(:refresh)
        indexer = Indexer.new(fake_client)
        indexer.refresh_index
      end
    end

    describe '#create_mapping' do
      it "updates the mapping" do
        fake_client.stub(:put_mapping).and_return(true)
        expect(fake_client).to receive(:put_mapping)
        indexer = Indexer.new(fake_client)
        indexer.create_mapping
      end
    end
  end

  describe '#settings' do
    it 'returns a simple hash' do
      indexer = Indexer.new({})
      expect(indexer.settings).to have_key('analyzer')
    end
  end

  describe '#mapping' do
    it 'returns a simple hash' do
      indexer = Indexer.new({})
      expect(indexer.mapping).to have_key('document_type')
    end
  end
end