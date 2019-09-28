# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Draft, type: :model do
  describe '#metadata' do
    it "should be initialized as a hash" do
      draft = Draft.new
      expect(draft.metadata).to eq({})
    end

    it "should be updated by setters" do
      draft = Draft.new
      draft.metadata = { 'title' => 'Boo' }
      draft.title = 'Yay'
      expect(draft.metadata).to eq('title' => 'Yay')
    end
  end

  describe '#work_data' do
    it "should include only work fields" do
      draft = Draft.new(title: "One", chapters: [{ content: "Two" }])
      expect(draft.work_data).to eq('title' => 'One')
    end
  end

  describe '#chapter_data' do
    it "should include only chapter fields" do
      draft = Draft.new(title: "One", chapters: [{ 'content' => "Two" }])
      expect(draft.chapter_data).to eq([{ 'content' => 'Two' }])
    end    
  end

  describe '#tag_data' do
    it "should be a hash of tag types and names" do
      draft = Draft.new(fandoms: "Testing")
      expect(draft.tag_data['Fandom']).to eq("Testing")
    end
  end

  describe '#creators' do
    it "returns an empty array when no users are set" do
      draft = Draft.new
      expect(draft.creators).to eq([])
    end
  end
end
