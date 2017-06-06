require "rails_helper"

RSpec.feature "Student certificates" do
  before do
    @original_certificates = ENV["CERTIFICATES"]
    ENV["CERTIFICATES"] = "a present value -- booleans don't work"
  end

  after do
    if @original_certificates.blank?
      ENV.delete("CERTIFICATES")
    end
  end

  scenario "generate a completion cert" do
    student = FactoryGirl.create(:student, :on_team)
    FactoryGirl.create(:team_submission, team: student.team)

    sign_in(student)

    within("#cert_completion") { click_button("Prepare my participation certificate") }

    expect(page).to have_link("Download my Participation Certificate",
                              href: student.certificates.current.file_url)
  end

  scenario "generate a regional grand prize cert" do
    student = FactoryGirl.create(:student, :on_team)

    rpe = FactoryGirl.create(:rpe)
    rpe.teams << student.team

    student.team.team_submissions.create!(integrity_affirmed: true, contest_rank: :semifinalist)

    sign_in(student)

    within("#cert_rpe_winner") { click_button("Prepare my winner's certificate") }

    expect(page).to have_link("Download my Regional Pitch Winner's Certificate",
                              href: student.certificates.rpe_winner.current.file_url)
  end
end
