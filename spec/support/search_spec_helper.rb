# frozen_string_literal: true

module SearchSpecHelper
  def index_and_refresh(index_klass, *items)
    indexer = index_klass.new
    items.each do |item|
      indexer.index_document(item)
    end
    indexer.refresh_index
  end
end
