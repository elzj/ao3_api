# frozen_string_literal: true

module SearchSpecHelper
  def index_and_refresh(index_klass, items)
    indexer = index_klass.new
    index_class = indexer.index_class.new
    items.each do |item|
      indexer.index_document(item)
    end
    index_class.refresh_index
  end
end
