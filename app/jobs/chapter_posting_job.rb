class ChapterPostingJob < ApplicationJob
  queue_as :default

  def perform(chapter)
    update_work(chapter)
    Chapter.update_positions(chapter.work_id)
  end

  def update_work(chapter)
    work = chapter.work
    work.set_completeness
    work.set_word_count
    work.save!
  end
end
