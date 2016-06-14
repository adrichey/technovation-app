require "rails_helper"

class ScoreSubmissionTest < Capybara::Rails::TestCase
  def setup
    create_test_scoring_environment

    @judge ||= CreateJudge.(email: "judge@judging.com",
                            password: "secret1234",
                            password_confirmation: "secret1234",
                            expertises: ScoreCategory.all)
    sign_in(@judge)

    visit judges_scores_path

    click_link 'Judge submission for Test team'

    within('.ideation') { choose 'No' }
    within('.technology') { choose 'Yes' }

    click_button 'Save'
  end

  def test_score_submission
    assert_equal 1, submission.scores.count
    assert_equal 7, submission.scores.last.total
  end

  def test_score_only_once
    assert !page.has_link?('Judge submission for Test team')
  end

  def test_edit_score
    click_link 'Edit'
    within('.ideation') { choose 'Yes' }
    within('.technology') { choose 'No' }
    click_button 'Save'

    assert_equal 1, submission.scores.count
    assert_equal 3, submission.scores.last.total
  end
end
