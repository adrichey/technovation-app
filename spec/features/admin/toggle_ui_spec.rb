require "rails_helper"

RSpec.feature "Admin UI for season toggles:" do
  before { sign_in(FactoryBot.create(:admin)) }

  scenario "toggle user signups" do
    %w{student mentor}.each do |scope|
      SeasonToggles.disable_signup(scope)
      visit edit_admin_season_schedule_settings_path

      check "season_toggles_#{scope}_signup"
      click_button "Save"

      expect(SeasonToggles.signup_enabled?(scope)).to be(true),
        "#{scope} signup was not enabled"
    end
  end

  scenario "set dashboard headlines" do
    %w{student mentor judge}.each do |scope|
      SeasonToggles.set_dashboard_text(scope, "")
      visit edit_admin_season_schedule_settings_path

      fill_in "season_toggles_#{scope}_dashboard_text",
        with: "Something short"

      click_button "Save"

      expect(SeasonToggles.dashboard_text(scope)).to eq("Something short"),
        "#{scope} dashboard text was not set"
    end
  end

  scenario "set the survey links" do
    %w{student mentor}.each do |scope|
      SeasonToggles.set_survey_link(scope, nil, nil)
      visit edit_admin_season_schedule_settings_path

      fill_in "season_toggles_#{scope}_survey_link_text", with: "Pre-survey"
      fill_in "season_toggles_#{scope}_survey_link_url", with: "google.com"

      click_button "Save"

      expect(SeasonToggles.survey_link(scope, :text)).to eq("Pre-survey"),
        "#{scope} survey link text was not set"

      expect(SeasonToggles.survey_link(scope, :url)).to eq("google.com"),
        "#{scope} survey link url was not set"
    end
  end

  scenario "configure team building enabled" do
    SeasonToggles.team_building_enabled = false
    visit edit_admin_season_schedule_settings_path

    check "season_toggles[team_building_enabled]"
    click_button "Save"

    expect(SeasonToggles.team_building_enabled?).to be true
  end

  scenario "configure team submissions editable" do
    SeasonToggles.team_submissions_editable = false
    visit edit_admin_season_schedule_settings_path

    check "season_toggles[team_submissions_editable]"
    click_button "Save"

    expect(SeasonToggles.team_submissions_editable?).to be true
  end

  scenario "configure team submissions not editable" do
    SeasonToggles.team_submissions_editable = true
    visit edit_admin_season_schedule_settings_path

    page.uncheck "season_toggles[team_submissions_editable]"
    click_button "Save"

    expect(SeasonToggles.team_submissions_editable?).to be false
  end

  scenario "configure regional pitch event selection" do
    SeasonToggles.select_regional_pitch_event = false
    visit edit_admin_season_schedule_settings_path

    check "season_toggles[select_regional_pitch_event]"
    click_button "Save"

    expect(SeasonToggles.select_regional_pitch_event?).to be true
  end

  scenario "configure scores & certificates" do
    SeasonToggles.display_scores = false
    visit edit_admin_season_schedule_settings_path

    check "season_toggles[display_scores]"
    click_button "Save"

    expect(SeasonToggles.display_scores?).to be true
  end

  scenario "configure judging rounds" do
    SeasonToggles.judging_round = :off

    visit edit_admin_season_schedule_settings_path
    choose "Quarterfinals"
    click_button "Save"
    expect(SeasonToggles.quarterfinals?).to be true

    visit edit_admin_season_schedule_settings_path
    choose "Semifinals"
    click_button "Save"
    expect(SeasonToggles.semifinals?).to be true

    visit edit_admin_season_schedule_settings_path
    choose "Off"
    click_button "Save"
    expect(SeasonToggles.judging_enabled?).to be false
  end
end
