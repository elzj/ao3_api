require 'rails_helper'

RSpec.describe SearchClient, type: :model do
  describe '.new_client' do
    it 'returns an elasticsearch client' do
      client = SearchClient.new_client
      expect(client).to respond_to(:search, :index)
    end
  end
end
