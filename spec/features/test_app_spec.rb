require 'capybara/rspec'
require "./app"

Capybara.app = App
require "spec_helper"

feature "Homepage" do
  scenario "has registration button" do
    visit "/"

    expect(page).to have_content("Register")

  end

  scenario "Registration button" do
    visit "/"

    click_link "Register"

    expect(page).to have_content("username")
  end

  scenario "Create an account" do
    visit "/register/"

    fill_in("username", :with => "pgrunde")
    fill_in("password", :with => "drowssap")

    click_button "Sign Up"

    expect(page).to have_content("Thank you for registering")

    fill_in("username", :with => "pgrunde")
    fill_in("password", :with => "drowssap")

    click_button "Login"

    expect(page).to have_content("Welcome, pgrunde")
  end
end