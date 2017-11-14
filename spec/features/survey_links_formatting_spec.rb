require "rails_helper"

RSpec.feature "Survey links formatting" do
  scenario "when the survey link has custom variables in the URL" do
    SeasonToggles.set_survey_link(
      :student,
      "take our survey",
      "...?email=[email_value]&country=[country_value]&state=[state_value]"
    )

    student = FactoryBot.create(:student)
    sign_in(student)

    expected_href = "...?email=#{student.account.email}"
    expected_href += "&country=#{FriendlyCountry.(student.account)}"
    expected_href += "&state=#{FriendlySubregion.(student.account)}"

    expect(page).to have_link("take our survey", href: expected_href)
  end
end
