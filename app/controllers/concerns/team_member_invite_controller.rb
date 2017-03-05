module TeamMemberInviteController
  extend ActiveSupport::Concern

  included do
    helper_method :account_type
  end

  def show
    if current_profile.full_access_enabled?
      @invite = current_profile.team_member_invites.find_by(invite_token: params.fetch(:id)) ||
        NullInvite.new
    else
      redirect_to [current_profile.type_name, :dashboard],
        error: t("controllers.invites.show.full_access_needed")
    end
  end

  def create
    @team_member_invite = TeamMemberInvite.new(team_member_invite_params)

    if @team_member_invite.save
      redirect_to [account_type, @team_member_invite.team],
        success: t("controllers.team_member_invites.create.success")
    else
      render :new
    end
  end

  def destroy
    @invite = TeamMemberInvite.find_by(team_id: current_profile.team_ids,
                                       invite_token: params.fetch(:id))
    @invite.destroy
    redirect_to :back, success: t("controllers.invites.destroy.success", name: @invite.invitee_name)
  end

  private
  def team_member_invite_params
    params.require(:team_member_invite).permit(:invitee_email, :team_id).tap do |params|
      params[:inviter] = current_profile
    end
  end

  def account_type
    "application"
  end

  class NullInvite
    def status
      "missing"
    end
  end
end
