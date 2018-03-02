class SubmissionsGrid
  include Datagrid

  attr_accessor :admin, :allow_state_search

  self.batch_size = 10

  scope do
    TeamSubmission.includes(:team).references(:teams)
  end

  column :division, mandatory: true do
    team.division_name.humanize
  end

  column :team_name,
    mandatory: true,
    order: "teams.name",
    html: true do |sub|
    link_to sub.team_name, [current_scope, sub.team]
  end

  column :team_name, html: false

  column :app_name, mandatory: true, html: true do |sub|
    link_to sub.app_name, [current_scope, sub]
  end

  column :app_name, html: false

  column :city, order: "teams.city" do
    team.city
  end

  column :state_province, header: "State"

  column :country do
    if found_country = Carmen::Country.coded(country)
      found_country.name
    end
  end

  column :progress,
    order: "team_submissions.percent_complete",
    mandatory: true,
    html: true do |submission|
    submission_progress_bar(submission)
  end

  column :progress, html: false do |submission|
    "#{submission.percent_complete}%"
  end

  filter :team_name do |value, scope, grid|
    scope.where("teams.name ilike ?", "#{value}%")
  end

  filter :app_name

  filter :division,
    :enum,
    select: [["Senior", "senior"], ["Junior", "junior"]] do |value|
      where(
        "teams.division_id = ?",
        Division.send(value).id
      )
    end

  filter :season,
    :enum,
    select: (2015..Season.current.year).to_a.reverse,
    filter_group: "more-specific",
    html: {
      class: "and-or-field",
    } do |value|
    by_season(value)
  end

  filter :country,
    :enum,
    header: "Country",
    select: ->(g) {
      CountryStateSelect.countries_collection
    },
    filter_group: "more-specific",
    multiple: true,
    data: {
      placeholder: "Select or start typing...",
    },
    if: ->(g) { g.admin } do |values|
      clauses = values.flatten.map { |v| "teams.country = '#{v}'" }
      where(clauses.join(' OR '))
    end

  filter :state_province,
    :enum,
    header: "State / Province",
    select: ->(g) {
      CS.get(g.country[0]).map { |s| [s[1], s[0]] }
    },
    filter_group: "more-specific",
    multiple: true,
    data: {
      placeholder: "Select or start typing...",
    },
    if: ->(g) {
      (g.admin or g.allow_state_search) and
        g.country.one? and
          CS.get(g.country[0]).any?
    } do |values, scope, grid|
      clauses = values.flatten.map do |v|
        state = State.new(v)
        "lower(teams.state_province) like '#{state.search_name}%'"
      end

      scope.where("teams.country = ?", grid.country)
        .where(clauses.join(' OR '))
    end

  filter :city,
    :enum,
    select: ->(g) {
      country = g.country[0]
      state = g.state_province[0]
      CS.get(country, state)
    },
    filter_group: "more-specific",
    multiple: true,
    data: {
      placeholder: "Select or start typing...",
    },
    if: ->(g) {
      country = g.country[0]
      state = g.state_province[0]
      g.state_province.one? && CS.get(country, state).any?
    } do |values, scope, grid|
      clauses = values.flatten.map do |v|
        v = v === "Mexico City" ? "Ciudad de México" : v
        "unaccent(teams.city) = unaccent('#{v}')"
      end

      state = State.new(grid.state_province[0])

      scope.where(
        "lower(teams.state_province) like '#{state.search_name}%'"
      )
        .where(clauses.join(' OR '))
    end

  column_names_filter(
    header: "More columns",
    filter_group: "more-columns",
    multiple: true
  )
end
