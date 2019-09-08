module SearchSpecHelper
  def index_and_refresh(index_klass, *items)
    indexer = index_klass.new
    indexer.index_records(items)
    indexer.refresh_index
  end
end