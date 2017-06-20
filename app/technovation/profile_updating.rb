class ProfileUpdating
  private
  attr_reader :profile, :scope

  public
  def initialize(profile, scope = nil)
    @profile = profile
    @scope = scope || profile.account.type_name
  end

  def self.execute(profile, scope = nil, attrs)
    new(profile, scope).update(attrs)
  end

  def update(attributes)
    if profile.update_attributes(attributes)
      perform_callbacks
      true
    else
      false
    end
  end

  def perform_callbacks
    perform_email_changes_updates
    AccountGeocoding.perform(profile.account)

    case scope.to_sym
    when :student
      perform_student_updates
    end

    profile.save
    profile.account.save
  end

  private
  def perform_student_updates
    Casting.delegating(profile => TeamDivisionChooser) do
      profile.reconsider_team_division
    end
  end

  def perform_email_changes_updates
    Casting.delegating(profile.account => EmailListUpdater) do
      profile.account.update_email_list_profile(scope)
    end
  end

  module EmailListUpdater
    def update_email_list_profile(scope)
      if email_list_changes_made?
        UpdateProfileOnEmailListJob.perform_later(
          id, email_before_last_save, "#{scope.upcase}_LIST_ID"
        )
      end
    end

    private
    def email_list_changes_made?
      saved_change_to_city? or
        saved_change_to_state_province? or
          saved_change_to_country? or

      saved_change_to_first_name? or
        saved_change_to_last_name? or

      saved_change_to_email?
    end
  end

  module TeamDivisionChooser
    def reconsider_team_division
      if team.present? and account.saved_change_to_date_of_birth?
        team.update_attributes({
          division_id: Division.for(team).id,
        })
      end
    end
  end
end