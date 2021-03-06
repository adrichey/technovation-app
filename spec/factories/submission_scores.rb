FactoryBot.define do
  factory :submission_score, aliases: [:score] do
    judge_profile
    association(:team_submission, factory: [:team_submission, :junior])
    round SubmissionScore.rounds[:quarterfinals]
    seasons [Season.current.year]

    trait :complete do
      completed_at Time.current
    end

    trait :senior do
      association(:team_submission, factory: [:team_submission, :senior])
    end

    trait :junior do
      association(:team_submission, factory: [:team_submission, :junior])
    end

    trait :brazil do
      association(:team_submission, factory: [:team_submission, :brazil])
    end

    trait :los_angeles do
      association(
        :team_submission,
        factory: [:team_submission, :los_angeles]
      )
    end

    trait :chicago do
      association(:team_submission, factory: [:team_submission, :chicago])
    end

    trait :minimum_total do
      sdg_alignment 5
      evidence_of_problem 5
      problem_addressed 5
      app_functional 5
      business_plan_short_term 5
    end
  end
end
