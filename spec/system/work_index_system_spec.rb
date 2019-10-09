require "rails_helper"

RSpec.describe "Work Browsing", type: :system, work_search: true do
  before do
    driven_by(:rack_test)
  end

  context "given valid data" do
    it "works" do
      visit "/works"
      expect(page).to have_text("Works")
    end
  end
end
