class WorkBlurb
  include ActionView::Helpers::TagHelper
  delegate :url_helpers, to: 'Rails.application.routes'

  attr_accessor :output_buffer
  attr_reader :work

  def initialize(work_document)
    @work = work_document
  end

  def as_json(options = {})
    doc = work.dup
    if unrevealed?
      return {
        id: id,
        title: "Mystery Work"
      }
    end
    if anonymous?
      doc.delete(:creators)
      doc.delete(:authors_to_sort_on)
    end
    doc
  end

  def id
    work['id']
  end

  def title
    work['title']
  end

  def summary
    work['summary']
  end

  def language
    work['language'] || 'en'
  end

  def revised_at
    work['revised_at']&.to_date
  end

  def date_string
    revised_at&.strftime("%d %b %Y")
  end

  def anonymous?
    work['anonymous']
  end

  def unrevealed?
    work['unrevealed']
  end

  def word_count
    work['word_count']
  end

  def chapter_count
    current = work['chapters_posted']
    expected = work['chapters_expected'] || '?'
    "#{current}/#{expected}"
  end

  def comments_count
    work['comments_count']
  end

  def bookmarks_count
    work['bookmarks_count']
  end

  def kudos_count
    work['kudos_count']
  end

  def hit_count
    work['hit_count']
  end

  def collection_count
    collections.length
  end

  def collections
    work['collections'] || []
  end

  def series
    work['series'] || []
  end

  def tags
    work['tags'] || []
  end

  def creators
    work['creators'] || []
  end

  def icon_block
    blocks = [
      rating_icon_li,
      media_icon_li,
      warning_icon_li,
      complete_icon_li
    ]
    "<ul class='required-tags'>#{blocks.join}</ul>".html_safe
  end

  def rating_icon_li
    rating = tags.find { |tag| tag['type'] == 'Rating' }
    val= rating['name']
    name = val.split(" ").first.downcase
    content_tag(:li, class: 'rating') do
      content_tag(:span, class: "rating-#{name}", title: val) do
        content_tag(:span, class: "text") { val }
      end
    end
  end

  def media_icon_li
    media = 'text'
    content_tag(:li, class: 'media') do
      content_tag(:span, class: "media-#{media}", title: media) do
        content_tag(:span, class: "text") { media }
      end
    end
  end

  def warning_icon_li
    warnings = tags.select { |tag| tag['type'] == 'ArchiveWarning' }
    names = warnings.map { |w| w['name'] }
    desc  = if names.length == 1 && names.first =~ /No Archive Warnings/
              "no"
            elsif names.length == 1 && names.first =~ /Choose Not/
              "maybe"
            else
              "yes"
            end
    val = names.join(', ')
    content_tag(:li, class: 'warning') do
      content_tag(:span, class: "warning-#{desc}", title: val) do
        content_tag(:span, class: "text") { val }
      end
    end
  end

  def complete_icon_li
    val = complete? ? 'Complete' : 'Incomplete'
    content_tag(:li, class: 'wip') do
      content_tag(:span, class: "#{val.downcase}", title: val) do
        content_tag(:span, class: "text") { val }
      end
    end
  end

  def complete?
    work['complete']
  end

  def creator_links
    return [{ name: 'Anonymous' }] if work['anonymous']
    creators.map{ |creator| creator_link(creator) }
  end

  def creator_link(creator)
    url = url_helpers.user_pseud_works_url(
      user_id: creator['user_login'],
      pseud_id: creator['name'],
      id: creator['name'],
      host: ArchiveConfig.host
    )
    { name: byline(creator), url: url }
  end

  def byline(creator)
    name = creator['name']
    login = creator['user_login']
    name == login ? name : "#{name} (#{login})"
  end

  def creator_link_string
    return 'Anonymous' if work['anonymous']
    creator_links.map do |link|
      "<a href='#{link[:url]}'>#{link[:name]}</a>"
    end.join(', ').html_safe
  end

  def series_links
    series.map do |ser|
      { url: "/series/#{ser['id']}", name: ser['title'] }
    end
  end

  def series_html_links
    series.map do |ser|
      count = ser['position']
      url = "/series/#{ser['id']}"
      title = ser['title']
      "Part #{count} of <a href='#{url}'>#{title}</a>"
    end
  end

  def collection_count_link
    "<a href='/works/#{id}/collections'>#{collection_count}</a>".html_safe
  end

  def tag_links(tag_type)
    return [] unless tags.present?
    tags.map { |tag| tag_link(tag) if tag['type'] == tag_type }.compact
  end

  def tag_link(tag)
    param = tag['name'].parameterize[0..50]
    url = url_helpers.tag_works_url(
      tag_id: "#{tag['id']}-#{param}",
      host: ArchiveConfig.host
    )
    { name: tag['name'], url: url }
  end

  def fandom_links
    tag_links('Fandom')
  end

  def fandom_link_string
    fandom_links.map do |fandom_link|
      "<a href='#{fandom_link[:url]}'>#{fandom_link[:name]}</a>"
    end.join(', ').html_safe
  end

  def tag_li_list
    tag_types = %w(ArchiveWarning Relationship Character Category Freeform)
    tag_types.map do |tag_type|
      tag_links(tag_type).map do |link|
        content_tag(:li, class: tag_type.underscore.pluralize) do
          content_tag(:a, href: link[:url], class: 'tag') do
            link[:name]
          end
        end
      end
    end.flatten.join.html_safe
  end
end
