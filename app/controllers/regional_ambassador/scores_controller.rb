require "will_paginate/array"

module RegionalAmbassador
  class ScoresController < RegionalAmbassadorController
    def index
      params[:page] ||= 1
      params[:per_page] ||= 15
      params[:round] ||= "quarterfinals"

      @division = params[:division] ||= "senior"

      events = RegionalPitchEvent.in_region(current_ambassador)
      virtual_event = VirtualRegionalPitchEvent.new

      if virtual_event.teams.in_region(current_ambassador).any?
        params[:event] ||= "virtual"

        @event = if params[:event] == "virtual"
                  virtual_event
                else
                  events.eager_load(
                    teams: { team_submissions: :submission_scores }
                  ).find(params[:event])
                end

        @events = [virtual_event] + events.sort_by(&:name)
      elsif events.any?
        params[:event] ||= events.pluck(:id).sort.first

        @event = events.eager_load(
          teams: { team_submissions: :submission_scores }
        ).find(params[:event])

        @events = events.sort_by(&:name)
      else
        @events = RegionalPitchEvent.none
        @event = virtual_event
      end

      @submissions = get_sorted_paginated_submissions_in_requested_division
    end

    def show
      params[:round] ||= "quarterfinals"

      @team_submission = TeamSubmission.includes(
        team: :division,
        submission_scores: { judge_profile: :account }
      ).friendly.find(params[:id])

      @team = @team_submission.team

      @event = @team.selected_regional_pitch_event

      @scores = @team_submission.submission_scores
        .send(params[:round])
        .complete
        .includes(judge_profile: :account)
        .references(:accounts)
        .order("accounts.first_name")
    end

    private
    def get_sorted_paginated_submissions_in_requested_division(page = params[:page])
      submissions = @event.team_submissions
        .includes(:submission_scores, team: :regional_pitch_events)
        .in_region(current_ambassador)
        .public_send(params[:division])
        .select { |s| s.team.selected_regional_pitch_event.live? or s.complete? }
        .sort { |a, b|
          case params.fetch(:sort) { "avg_score_desc" }
          when "avg_score_desc"
            b.send("#{params[:round]}_average_score") <=>
              a.send("#{params[:round]}_average_score")
          when "avg_score_asc"
            a.send("#{params[:round]}_average_score") <=>
              b.send("#{params[:round]}_average_score")
          when "team_name"
            a.team.name <=> b.team.name
          end
        }.paginate(page: page.to_i, per_page: params[:per_page].to_i)

      if submissions.empty? and page.to_i != 1
        get_sorted_paginated_submissions_in_requested_division(1)
      else
        submissions
      end
    end
  end
end
