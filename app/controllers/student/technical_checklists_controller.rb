module Student
  class TechnicalChecklistsController < StudentController
    def edit
      @technical_checklist = current_team.team_submissions.last.technical_checklist ||
        current_team.team_submissions.last.create_technical_checklist!
    end

    def update
      @technical_checklist = current_team.team_submissions.last.technical_checklist

      if @technical_checklist.update_attributes(technical_checklist_params)
        redirect_to [:student, current_team.team_submissions.last],
          success: "Your technical checklist was saved!"
      else
        render :edit
      end
    end

    private
    def technical_checklist_params
      params.require(:technical_checklist).permit(
        :used_strings,
        :used_strings_explanation,
        :used_numbers,
        :used_numbers_explanation,
        :used_variables,
        :used_variables_explanation,
        :used_lists,
        :used_lists_explanation,
        :used_booleans,
        :used_booleans_explanation,
        :used_loops,
        :used_loops_explanation,
        :used_conditionals,
        :used_conditionals_explanation,
        :used_local_db,
        :used_local_db_explanation,
        :used_external_db,
        :used_external_db_explanation,
        :used_location_sensor,
        :used_location_sensor_explanation,
        :used_camera,
        :used_camera_explanation,
        :used_accelerometer,
        :used_accelerometer_explanation,
        :used_sms_phone,
        :used_sms_phone_explanation,
        :used_sound,
        :used_sound_explanation,
        :used_sharing,
        :used_sharing_explanation,
        :used_clock,
        :used_clock_explanation,
        :used_canvas,
        :used_canvas_explanation,
        :paper_prototype,
        :paper_prototype_cache,
        :event_flow_chart,
        :event_flow_chart_cache,
      )
    end
  end
end
