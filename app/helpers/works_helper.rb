module WorksHelper
  # Given a particular set of facets/aggregations,
  # return the tag headings
  def tag_facet_keys
    Tag::TAGGABLE_TYPES.map { |tag_type| tag_type.underscore.pluralize }
  end

  # Don't collapse lists with selected filters
  def filter_group_div(search, facets, key)
    classes = 'filter collapse'
    values = facets[key]
    if values.blank? || search.send(values.first.field).present?
      classes += ' show'
    end
    content_tag(:div, class: classes, id: "collapse-#{key}") do
      yield
    end
  end
end
