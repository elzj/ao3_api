require "rails_helper"

RSpec.describe "User authentication", type: :system do
  before do
    driven_by(:rack_test)
  end

  context "as a confirmed user" do
    let!(:user) do
      create(:user,
        password: "password",
        password_confirmation: "password",
        confirmed_at: Time.now
      )
    end

    it "signs me in with the right password" do
      visit "/users/login"

      fill_in "Login", with: user.login
      fill_in "Password", with: "password"
      click_button "Log in"

      expect(page).to have_text("Signed in successfully")
    end

    it "does not sign me in with the wrong password" do
      visit "/users/login"

      fill_in "Login", with: user.login
      fill_in "Password", with: "wrong"
      click_button "Log in"

      expect(page).to have_text("Invalid login or password")
    end
  end

  context "as an unconfirmed user" do
    let!(:user) do
      create(:user,
        password: "password",
        password_confirmation: "password",
        confirmed_at: nil
      )
    end

    it "tells me to confirm my account" do
      visit "/users/login"

      fill_in "Login", with: user.login
      fill_in "Password", with: "password"
      click_button "Log in"

      expect(page).to have_text("You have to confirm your email address")
    end
  end
end
