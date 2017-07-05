require "rails_helper"

RSpec.feature "Students view scores" do
  before do
    @enable_scores = ENV.fetch("ENABLE_TEAM_SCORES") { false }
    ENV["ENABLE_TEAM_SCORES"] = "yes"
  end

  after do
    if @enable_scores
      ENV["ENABLE_TEAM_SCORES"] = @enable_scores
    else
      ENV.delete("ENABLE_TEAM_SCORES")
    end
  end

  scenario "view QF scores" do
    submission = FactoryGirl.create(
      :submission,
      :complete,
      technical_checklist_attributes: {
        used_camera: true,
        used_camera_explanation: "We did it...",
      }
    )

    FactoryGirl.create(:submission_score, :complete, team_submission: submission)

    sign_in(submission.team.students.sample)

    expect(page).to have_content("earned 2 points")
  end

  scenario "view SF scores" do
    submission = FactoryGirl.create(
      :submission,
      :complete,
      :semifinalist,
      technical_checklist_attributes: {
        used_camera: true,
        used_camera_explanation: "We did it...",
      }
    )

    FactoryGirl.create(
      :score,
      :complete,
      round: :semifinals,
      team_submission: submission
    )

    sign_in(submission.team.students.sample)

    expect(page).to have_content("earned 2 points")
  end
end