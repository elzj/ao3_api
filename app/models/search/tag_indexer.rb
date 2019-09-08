class TagIndexer < Indexer
  def index_name
    SearchHelper.index_name('tags')
  end

  def klass
    "Tag"
  end

  def document_type
    "tag"
  end

  def document(record)
    TagDocument.new(record).to_hash
  end
end
