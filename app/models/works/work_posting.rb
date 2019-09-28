class WorkPosting
  REQUIRED_FIELDS = %i(title fandoms ratings archive_warnings creators language_id)

  def self.build(attributes = {})
    draft = Draft.new(attributes)   
    new(draft)
  end

  attr_reader :draft, :errors, :work
  
  def initialize(draft)
    @draft = draft
    @work = Work.new(draft.work_data.merge(posted: true))
    @errors = []
  end

  def post!
    valid? && Draft.transaction {
      save_work
      save_tags
      draft.destroy if draft.persisted?
      work
    }
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved => e
    @errors << e.message
    false
  end

  def valid?
    REQUIRED_FIELDS.each do |field|
      if draft.send(field).blank?
        errors << "#{field.to_s.singularize.humanize} is missing"
      end
    end
    errors.empty?
  end

  def save_work
    build_creatorships
    build_chapters
    work.save!
  end

  def build_creatorships
    Pseud.find(draft.creators).each do |pseud|
      work.creatorships.build(pseud_id: pseud.id)
    end
  end

  def build_chapters
    draft.chapters.each do |chapter_data|
      work.chapters.build(chapter_data.merge(posted: true))
    end
  end

  def save_tags
    draft.tag_data.each_pair do |tag_type, tag_string|
      next if tag_string.blank?
      if tag_string.is_a?(Array)
        tag_string = tag_string.reject(&:empty?).join(',')
      end

      tags = Tag.process_tag_list(tag_type, tag_string)
      tags.each do |tag|
        work.taggings.create!(tagger_id: tag.id, tagger_type: 'Tag')
      end
    end
  end
end
