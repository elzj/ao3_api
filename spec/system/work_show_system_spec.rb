require "rails_helper"

RSpec.describe "Work Show", type: :system do
  before do
    driven_by(:rack_test)
  end

  context "given valid data" do
    let(:work) { create(:work, title: "Hello World") }

    before { work.create_stat_counter }

    it "works" do
      visit "/works/#{work.id}"
      expect(page).to have_text("Hello World")
    end
  end
end
