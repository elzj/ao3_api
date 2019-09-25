# frozen_string_literal: true

module Search
  class Client
    attr_reader :client

    def initialize(host=nil)
      host ||= ArchiveConfig.search[:url]
      @client = Elasticsearch::Client.new(host: host)
    end

    def self.new_client
      new.client
    end
  end
end
