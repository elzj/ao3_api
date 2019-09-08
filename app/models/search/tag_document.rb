class TagDocument
  attr_reader :tag
  
  def initialize(tag)
    @tag = tag
  end

  def to_hash
    tag.as_json(
      root: false,
      only: [
        :id, :name, :sortable_name, :merger_id, :canonical, :created_at,
        :unwrangleable
      ]
    ).merge(
      has_posted_works: tag.has_posted_works?,
      tag_type: tag.type,
      uses: tag.taggings_count_cache
    ).merge(parent_data(tag))
  end

  # Index parent data for tag wrangling searches
  def parent_data(tag)
    data = {}
    # %w(Media Fandom Character).each do |parent_type|
    #   if tag.parent_types.include?(parent_type)
    #     key = "#{parent_type.downcase}_ids"
    #     data[key] = tag.parents.by_type(parent_type).pluck(:id)
    #     next if parent_type == "Media"
    #     data["pre_#{key}"] = tag.suggested_parent_ids(parent_type)
    #   end
    # end
    data
  end
end
