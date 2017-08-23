require "rails_helper"

RSpec.feature "Register as a student" do
  before do
    set_signup_token("student@student.com")

    visit student_signup_path

    fill_in "First name", with: "Student"
    fill_in "Last name", with: "McGee"

    select_date Date.today - 15.years, from: "Date of birth"

    fill_in "School name", with: "John Hughes High."

    click_button "Create Your Account"
  end

  scenario "Redirected to student dashboard" do
    expect(current_path).to eq(student_dashboard_path)
  end

  scenario "saves location details" do
    click_link "Update your location"

    fill_in "City", with: "Chicago"
    fill_in "State / Province", with: "IL"
    select "United States", from: "Country"
    click_button "Save"

    expect(StudentProfile.last.address_details).to eq(
      "Chicago, IL, United States"
    )
    expect(StudentProfile.last.account).to be_location_confirmed
  end

  scenario "signup attempt attached" do
    attempt = SignupAttempt.find_by(
      account_id: StudentProfile.last.account_id
    )
    expect(attempt).to be_present
  end

  scenario "email is confirmed on signup" do
    visit student_dashboard_path
    expect(page).not_to have_content("You changed your email address")
  end
end
