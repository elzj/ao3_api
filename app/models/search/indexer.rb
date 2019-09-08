class Indexer
  attr_reader :client

  def initialize(client=nil)
    @client = client || SearchClient.new_client
  end

  def index_name
    "redefine_me"
  end

  def document_type
    "things"
  end

  def klass
    "Test"
  end

  def delete_index
    if client.indices.exists(index: index_name)
      client.indices.delete(index: index_name)
    end
  end

  def create_index(shards = 5)
    client.indices.create(
      index: index_name,
      body: {
        settings: {
          index: {
            # static settings
            number_of_shards: shards,
            # dynamic settings
            max_result_window: ArchiveConfig.search[:max_results],
          }
        }.merge(settings),
        mappings: mapping,
      }
    )
  end

  def refresh_index
    client.indices.refresh(index: index_name)
  end

  # Note that the index must exist before you can set the mapping
  def create_mapping
    client.indices.put_mapping(
      index: index_name,
      type: document_type,
      body: mapping
    )
  end

  def settings
    load_file_json("settings")
  end

  def mapping
    load_file_json("mappings")
  end

  def load_file_json(filetype)
    file = File.join(
      File.dirname(__FILE__),
      "#{filetype}/#{klass.underscore.pluralize}.json"
    )
    JSON.parse(File.read(file))
  end

  def prepare_for_testing
    raise "Wrong environment for test prep!" unless Rails.env.test?
    delete_index
    create_index
    refresh_index
  end

  def index_records(records)
    records.each { |record| index_record(record) }
  end

  def index_record(record)
    info = {
      index: index_name,
      type: document_type,
      id: document_id(record),
      body: document(record)
    }
    client.index(info)
  end

  def document_id(record)
    record.id
  end

  def document(record)
    record.as_json(root: false)
  end
end
