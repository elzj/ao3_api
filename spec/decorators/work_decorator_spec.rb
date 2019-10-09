require 'rails_helper'

RSpec.describe WorkDecorator do
  it "knows its title" do
    work = Work.new(title: "foo")
    dec = work.decorate
    expect(dec.title).to eq("foo")
  end

  describe '#chapters' do
    it "returns posted chapters in order" do
      work = build_stubbed(:work)
      chapter1 = work.chapters.create(position: 1, posted: false, content: 'an unposted chapter')
      chapter3 = work.chapters.create(position: 3, posted: true, content: 'final posted chapter')
      chapter2 = work.chapters.create(position: 2, posted: true, content: 'first posted chapter')

      dec = work.decorate
      expect(dec.chapters).to eq([chapter2, chapter3])
    end
  end

  describe '#chapter_count' do
    it "returns the current number of posted and expected chapters" do
      work = build_stubbed(:work, chapters_expected: 5)
      chapter1 = work.chapters.create(position: 1, posted: true, content: 'a posted chapter')
      dec = work.decorate
      expect(dec.chapter_count).to eq("1/5")
    end

    it "uses a ? when expected chapters is nil" do
      dec = build(:work, chapters_expected: nil).decorate
      expect(dec.chapter_count).to eq("0/?")
    end
  end

  describe '#creator_links' do
    it "returns html creator links" do
      creator1 = create(:pseud)
      creator2 = create(:pseud)
      work = build_stubbed(:work)
      work.pseuds = [creator1, creator2]

      dec = work.decorate
      links = "<a href=\"/users/#{creator1.user_login}/pseuds/#{creator1.name}/works\">#{creator1.byline}</a> and <a href=\"/users/#{creator2.user_login}/pseuds/#{creator2.name}/works\">#{creator2.byline}</a>"
      expect(dec.creator_links).to eq(links)
    end

    it "returns Anonymous for anon works" do
      dec = build(:work, in_anon_collection: true).decorate
      expect(dec.creator_links).to eq("Anonymous")
    end
  end

  context 'stats' do
    it "delegates counter fields to the stat counter" do
      work = build_stubbed(:work)
      work.stat_counter = StatCounter.new(
        comments_count: 1,
        bookmarks_count: 2,
        kudos_count: 3,
        hit_count: 4
      )
      dec = work.decorate
      expect(dec.comments_count).to eq(1)
      expect(dec.bookmarks_count).to eq(2)
      expect(dec.kudos_count).to eq(3)
      expect(dec.hit_count).to eq(4)
    end
  end

  describe '#tag_data' do
    it "returns a hash of tag data" do
      work = build_stubbed(:work)
      tag = create(:freeform)
      work.taggings.create(tagger_id: tag.id)
      dec = work.decorate

      expect(dec.tag_data).to eq('Freeform' => [tag])
    end
  end

  describe '#tags_for_type' do
    it 'returns a definition list pair for a given tag type' do
      work = build_stubbed(:work)
      tag = create(:freeform)
      work.taggings.create(tagger_id: tag.id)
      dec = work.decorate

      html = "<dt>Freeforms:</dt>"\
             "<dd><ul class=\"tags commas\"><li>"\
             "<a href=\"/tags/#{tag.to_param}/works\">#{tag.name}</a>"\
             "</li></ul></dd>"

      expect(dec.tags_for_type('Freeform')).to match(html)
    end
  end
end
