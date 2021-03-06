module RegionalAmbassador
  class PrintableScoresController < RegionalAmbassadorController
    layout "printable_scores"

    def show
      @event = RegionalPitchEvent.includes(
        judges: :submission_scores,
        team_submissions: :submission_scores
      ).find(params[:id])

      judges = @event.judges
      scores = @event.team_submissions
                 .flat_map(&:complete_submission_scores)

      if judges.any? { |j| j.assigned_teams.any? }
        @groups = {}
        included = []

        judges.each.with_index do |judge, idx|
          next if included.include?(judge.id)

          others_with_same_teams = judges.select do |j|
            j.id != judge.id && j.assigned_teams == judge.assigned_teams
          end

          @groups[idx] = judge.submission_scores.complete
          @groups[idx] += others_with_same_teams.flat_map { |j| j.submission_scores.complete }

          included << judge.id
          included += others_with_same_teams.map(&:id)
        end
      else
        @groups = { 0 => scores.sort_by(&:judge_name) }
      end

      @groups = @groups.reject { |i, s| s.empty? }
    end
  end
end
