module Student
  class ScoresController < StudentController
    def show
      @score = current_team.submission.submission_scores.quarterfinals.find(params[:id])
    end
  end
end
