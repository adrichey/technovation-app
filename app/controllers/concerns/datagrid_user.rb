module DatagridUser
  extend ActiveSupport::Concern

  included do
    helper_method :default_or_saved_search_params?,
      :default_export_filename,
      :param_root

    before_action -> {
      @saved_searches = current_profile.saved_searches
        .for_param_root(param_root)

      @saved_search = current_profile.saved_searches.build
    }, only: :index
  end

  module ClassMethods
    attr_accessor :using_datagrid_with_klass,
      :html_scope_modifier,
      :csv_scope_modifier

    def use_datagrid(opts)
      unless opts[:with]
        raise "use_datagrid caller must specify :with class"
      end

      @using_datagrid_with_klass = opts[:with]

      @html_scope_modifier = opts[:html_scope] || ->(scope, user, params) {
        scope.page(params[:page])
      }

      @csv_scope_modifier = opts[:csv_scope] || ->(scope, user, params) {
        scope
      }
    end
  end

  def index
    respond_to do |f|
      f.html do
        instance_variable_set(
          "@#{param_root}",
          grid_klass.new(grid_params) { |scope|
            modify_html_scope(scope)
          }
        )
      end

      f.csv do
        instance_variable_set(
          "@#{param_root}",
          grid_klass.new(grid_params) { |scope|
            modify_csv_scope(scope)
          }
        )

        send_export(instance_variable_get("@#{param_root}"), :csv)
      end
    end
  end

  private
  def modify_html_scope(scope)
    self.class.html_scope_modifier.call(scope, current_profile, params)
  end

  def modify_csv_scope(scope)
    self.class.csv_scope_modifier.call(scope, current_profile, params)
  end

  def detect_extra_columns(grid_params)
    columns = Array(grid_params[:column_names]).flatten.map(&:to_sym)

    if Array(grid_params[:country]).many?
      columns = columns | [:country]
    end

    if not Array(grid_params[:state_province]).one? and
        (Array(grid_params[:state_province]).many? or
          Array(grid_params[:country]).one?)
      columns = columns | [:state_province]
    end

    if Array(grid_params[:city]).any? or
        Array(grid_params[:state_province]).one?
      columns = columns | [:city]
    end

    if Array(grid_params[:profile_type]).many? or
        grid_params[:team_matching].present?
      columns = columns | [:profile_type]
    end

    columns
  end

  def default_or_saved_search_params?
    SavedSearch.default_or_saved_search_params?(params, param_root, current_profile)
  end

  def param_root
    @param_root ||= grid_klass.name.underscore
  end

  def grid_klass
    @grid_klass ||= self.class.using_datagrid_with_klass
  end

  def send_export(collection, format)
    passed_filename = params[:filename].sub(".#{format}", "")

    filename = if passed_filename.blank?
                 default_export_filename(format)
               else
                 "#{passed_filename}.#{format}"
               end

    send_data collection.public_send("to_#{format}"),
      type: "text/csv",
      disposition: 'inline',
      filename: filename
  end

  def default_export_filename(format)
    case param_root
    when "accounts_grid"
      "technovation-participants-#{Time.current}.#{format}"
    when "teams_grid"
      "technovation-teams-#{Time.current}.#{format}"
    end
  end
end
