require "rails_helper"

RSpec.describe "User registration", type: :system do
  before do
    driven_by(:rack_test)
  end

  context "given valid data" do
    it "enables me to sign up" do
      visit "/users/sign_up"

      fill_in "Login", with: "myself"
      fill_in "Email", with: "myself@example.com"
      fill_in "Password", with: "password"
      fill_in "Password confirmation", with: "password"
      click_button "Sign up"

      expect(page).to have_text("A message with a confirmation link has been sent to your email address. Please follow the link to activate your account.")
    end
  end

  context "given invalid data" do
    it "gives me an error message" do
      visit "/users/sign_up"

      fill_in "Login", with: "myself"
      fill_in "Password", with: "password"
      fill_in "Password confirmation", with: "password"
      click_button "Sign up"

      expect(page).to have_text("Email can't be blank")
    end
  end
end
