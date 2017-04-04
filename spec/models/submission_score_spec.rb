require "rails_helper"

RSpec.describe SubmissionScore do
  it "cannot be duplicated for the same submission and judge" do
    team = Team.create!(name: "A", description: "B", division: Division.senior)
    team_submission = TeamSubmission.create!(team_id: team.id, integrity_affirmed: true)
    judge_profile = FactoryGirl.create(:judge_profile)

    second_team_submission = TeamSubmission.create!(team_id: team.id, integrity_affirmed: true)
    second_judge_profile = FactoryGirl.create(:judge_profile)

    SubmissionScore.create!(
      judge_profile_id: judge_profile.id,
      team_submission_id: team_submission.id,
    )

    expect {
      SubmissionScore.create!(
        judge_profile_id: judge_profile.id,
        team_submission_id: team_submission.id,
      )
    }.to raise_error(ActiveRecord::RecordInvalid)

    expect {
      SubmissionScore.create!(
        judge_profile_id: judge_profile.id,
        team_submission_id: second_team_submission.id,
      )

      SubmissionScore.create!(
        judge_profile_id: second_judge_profile.id,
        team_submission_id: team_submission.id,
      )
    }.not_to raise_error
  end

  it "reports completeness" do
    team = Team.create!(name: "A", description: "B", division: Division.senior)
    team_submission = TeamSubmission.create!(team_id: team.id, integrity_affirmed: true)
    judge_profile = FactoryGirl.create(:judge_profile)

    subscore = SubmissionScore.create!({
      team_submission: team_submission,
      judge_profile: judge_profile,
    })

    expect(subscore).not_to be_complete

    subscore.update_attributes({
      sdg_alignment: 0,
      evidence_of_problem: 0,
      problem_addressed: 0,
      app_functional: 0,

      demo_video: 0,
      business_plan_short_term: 0,
      business_plan_long_term: 0,
      market_research: 0,

      viable_business_model: 0,
      problem_clearly_communicated: 0,
      compelling_argument: 0,
      passion_energy: 0,

      pitch_specific: 0,
      business_plan_feasible: 0,
      submission_thought_out: 0,

      cohesive_story: 0,
      solution_originality: 0,
      solution_stands_out: 0,

      ideation_comment: "text",
      technical_comment: "text",
      entrepreneurship_comment: "text",
      pitch_comment: "text",
      overall_comment: "text",
    })

    expect(subscore).to be_complete
  end

  it "calculates scores" do
    team = Team.create!(name: "A", description: "B", division: Division.senior)
    team_submission = TeamSubmission.create!(team_id: team.id, integrity_affirmed: true)
    judge_profile = FactoryGirl.create(:judge_profile)

    subscore = SubmissionScore.create!({
      team_submission: team_submission,
      judge_profile: judge_profile,

      sdg_alignment: 3,
      evidence_of_problem: 5,
      problem_addressed: 4,
      app_functional: 2,

      demo_video: 0,
      business_plan_short_term: 5,
      business_plan_long_term: 5,
      market_research: 3,

      viable_business_model: 4,
      problem_clearly_communicated: 2,
      compelling_argument: 1,
      passion_energy: 5,

      pitch_specific: 5,
      business_plan_feasible: 4,
      submission_thought_out: 4,

      cohesive_story: 4,
      solution_originality: 3,
      solution_stands_out: 5,
    })

    expect(subscore.total).to eq(64)
  end

  it "calculates total possible score based on division" do
    team = Team.create!(name: "A", description: "B", division: Division.senior)
    team_submission = TeamSubmission.create!(team_id: team.id, integrity_affirmed: true)
    judge_profile = FactoryGirl.create(:judge_profile)

    subscore = SubmissionScore.create!({
      team_submission: team_submission,
      judge_profile: judge_profile,
    })

    expect(subscore.total_possible).to eq(100)

    team.division = Division.junior
    team.save!

    team_submission.reload

    expect(subscore.total_possible).to eq(80)
  end

  it "includes tech checklist verification in the score" do
    team = Team.create!(name: "A", description: "B", division: Division.senior)
    team_submission = TeamSubmission.create!(team_id: team.id, integrity_affirmed: true)
    judge_profile = FactoryGirl.create(:judge_profile)

    team_submission.create_technical_checklist!({
      used_canvas_verified: true,
      used_clock_verified: true,
      used_lists_verified: true,
      used_accelerometer_verified: true,
    });

    subscore = SubmissionScore.create!({
      team_submission: team_submission,
      judge_profile: judge_profile,
    })

    expect(subscore.total).to eq(4)
  end
end
