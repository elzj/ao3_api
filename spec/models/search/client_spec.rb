# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Search::Client, type: :model do
  describe '.new_client' do
    it 'returns an elasticsearch client' do
      client = Search::Client.new_client
      expect(client).to respond_to(:search, :index)
    end
  end
end
