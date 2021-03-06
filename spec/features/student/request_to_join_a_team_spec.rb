require "rails_helper"

RSpec.feature "Students request to join a team",
  vcr: { match_requests_on: [:method, :host] } do
  include ActionView::RecordIdentifier

  before { SeasonToggles.team_building_enabled! }

  scenario "students already on a team don't see the link" do
    student = FactoryBot.create(:student, :on_team, not_onboarded: true)
    sign_in(student)
    expect(page).not_to have_link("Join a team")
  end

  %i{mentor student}.each do |scope|
    scenario "#{scope} searches after their request is declined" do
      user = FactoryBot.create(scope, :geocoded)
      team = FactoryBot.create(:team, :geocoded)

      user.join_requests.create!(
        team: team,
        declined_at: Time.current
      )

      sign_in(user)

      visit send("new_#{scope}_team_search_path")

      within(".search-result") do
        expect(page).to have_content(team.name)
        expect(page).to have_content(
          "You asked to join #{team.name}, and they declined."
        )
      end
    end
  end

  context "a valid student requestor" do
    let!(:team) { FactoryBot.create(:team, :with_mentor) }
      # Default is in Chicago

    let!(:student) { FactoryBot.create(:student, not_onboarded: true) }
      # Default Chicago

    before do
      ActionMailer::Base.deliveries.clear
      sign_in(student)
      visit new_student_join_request_path(team_id: team.id)
      click_button "Ask to join #{team.name}"
    end

    scenario "students not on a team request to join an available team" do
      expect(ActionMailer::Base.deliveries.count).not_to be_zero,
        "No join request email was sent"

      mail = ActionMailer::Base.deliveries.last

      expect(mail.subject).to eq("A student has asked to join your team!")
    end

    scenario "the requesting student can see their pending request" do
      within('.steps') do
        expect(page).to have_content("You have asked to join a team")
        expect(page).to have_content(team.name)
        expect(page).to have_content(team.primary_location)
        expect(page).to have_content(team.division_name.humanize)
        expect(page).to have_css("img.thumbnail-md[src*='#{team.team_photo_url}']")
      end

      expect(page).not_to have_link("Join a team")
    end

    scenario "student accepts the request" do
      ActionMailer::Base.deliveries.clear

      sign_out
      student = team.students.sample

      visit student_join_request_path(
        JoinRequest.last,
        mailer_token: student.mailer_token
      )

      click_button "Approve"

      expect(ActionMailer::Base.deliveries.count).not_to be_zero,
        "No join request approval email was sent"

      mail = ActionMailer::Base.deliveries.last
      expect(mail.to).to eq([JoinRequest.last.requestor_email])
      expect(mail.subject).to eq("Your request to join #{team.name} was accepted!")

      expect(mail.body.to_s).to include(
        "Hi #{JoinRequest.last.requestor_first_name}!"
      )

      expect(mail.body.to_s).to include(
        "#{team.name} accepted your request to be a member!"
      )

      url = student_team_url(
        team,
        mailer_token: JoinRequest.last.requestor_mailer_token,
        host: ENV["HOST_DOMAIN"],
        port: ENV["HOST_DOMAIN"].split(':')[1]
      )

      expect(mail.body.to_s).to include("href=\"#{url}\"")
    end

    scenario "student accepts from team page" do
      sign_out
      sign_in(team.students.sample)

      visit student_team_path(team)

      expect {
        within("#" + dom_id(JoinRequest.last)) do
          click_link "approve"
        end
      }.not_to raise_error
    end

    scenario "student declines from team page" do
      sign_out
      sign_in(team.students.sample)

      visit student_team_path(team)

      expect {
        within("#" + dom_id(JoinRequest.last)) do
          click_link "decline"
        end
      }.not_to raise_error
    end

    scenario "mentor accepts the request" do
      ActionMailer::Base.deliveries.clear

      sign_out
      mentor = team.mentors.sample
      visit mentor_join_request_path(
        JoinRequest.last,
        mailer_token: mentor.mailer_token
      )
      click_button "Approve"

      expect(ActionMailer::Base.deliveries.count).not_to be_zero,
        "No join request approval email was sent"
      mail = ActionMailer::Base.deliveries.last
      expect(mail.to).to eq([JoinRequest.last.requestor_email])
      expect(mail.subject).to eq("Your request to join #{team.name} was accepted!")
    end

    scenario "mentor accepts from team page" do
      sign_out
      sign_in(team.mentors.sample)

      visit mentor_team_path(team)

      expect {
        within("#" + dom_id(JoinRequest.last)) do
          click_link "approve"
        end
      }.not_to raise_error
    end

    scenario "mentor declines from team page" do
      sign_out
      sign_in(team.mentors.sample)

      visit mentor_team_path(team)

      expect {
        within("#" + dom_id(JoinRequest.last)) do
          click_link "decline"
        end
      }.not_to raise_error
    end

    scenario "student declines the request" do
      ActionMailer::Base.deliveries.clear

      sign_out
      student = team.students.sample

      visit student_join_request_path(
        JoinRequest.last,
        mailer_token: student.mailer_token
      )

      click_button "Decline"

      expect(ActionMailer::Base.deliveries.count).not_to be_zero,
        "No join request decline email was sent"

      mail = ActionMailer::Base.deliveries.last
      expect(mail.to).to eq([JoinRequest.last.requestor_email])
      expect(mail.subject).to eq("Your request to join #{team.name} was declined")
      expect(mail.body).to include("Hi #{JoinRequest.last.requestor_first_name},")
      expect(mail.body).to include(
        "#{team.name} has declined your request to be a member."
      )
    end

    scenario "mentor declines the request" do
      ActionMailer::Base.deliveries.clear

      sign_out
      mentor = team.mentors.sample

      visit mentor_join_request_path(
        JoinRequest.last,
        mailer_token: mentor.mailer_token
      )

      click_button "Decline"

      expect(ActionMailer::Base.deliveries.count).not_to be_zero,
        "No join request decline email was sent"

      mail = ActionMailer::Base.deliveries.last
      expect(mail.to).to eq([JoinRequest.last.requestor_email])
      expect(mail.subject).to eq("Your request to join #{team.name} was declined")
    end
  end
end
