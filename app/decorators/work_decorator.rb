# frozen_string_literal: true

class WorkDecorator < ApplicationDecorator
  delegate_all
  delegate :comments_count, :bookmarks_count, :kudos_count, :hit_count, to: :stats

  ### CHAPTERS ###

  def chapters
    @chapters ||= object.chapters.where(posted: true).order(:position)
  end

  def chapter_count
    current = chapters.length
    total = chapters_expected || "?"
    "#{current}/#{total}"
  end

  ### CREATORS ###

  def creator_links
    return "Anonymous" if anonymous?
    creators.map do |creator|
      url = "/users/#{creator.user_login}/pseuds/#{creator.name}/works"
      h.content_tag(:a, href: url) { creator.byline }
    end.to_sentence.html_safe
  end

  def creators
    @creators ||= object.pseuds.includes(:user)
  end

  ### META ###

  def language_name
    Language.name_for_short(language_id)
  end

  def stats
    @stats ||= object.stat_counter
  end

  ### COLLECTIONS ###

  ### RELATED WORKS ###

  ### SERIES ###

  ### TAGS ###

  def tag_data
    @tag_data ||= object.tags.group_by(&:type)
  end

  def tags_for_type(tag_type)
    tags = tag_data[tag_type]
    return if tags.blank?

    html = [h.content_tag(:dt, Tag.display_name(tag_type) + ":")]
    html << h.content_tag(:dd) do
      h.content_tag(:ul, class: "tags commas") do
        tag_lis(tags)
      end
    end
    html.join.html_safe
  end

  def tag_lis(tags)
    tags.map do |tag|
      h.content_tag(:li) do
        h.link_to(tag.name, h.tag_works_path(tag))
      end
    end.join('').html_safe
  end
end
