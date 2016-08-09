class TeamMemberInvite < ActiveRecord::Base
  enum status: %i{pending accepted rejected}

  before_create :generate_invite_token
  before_create :set_existing_invitee
  after_create :send_invite

  after_save :after_accept, if: -> { status_changed? && accepted? }

  belongs_to :team
  belongs_to :inviter, class_name: "Account"
  belongs_to :invitee, class_name: "StudentAccount"

  validates :invitee_email, presence: true

  delegate :email, to: :inviter, prefix: true
  delegate :name, to: :team, prefix: true

  def to_param
    invite_token
  end

  def after_accept
    team.add_student(invitee)
  end

  private
  def generate_invite_token
    GenerateToken.(self, :invite_token)
  end

  def send_invite
    TeamMailer.invite_member(self).deliver_later
  end

  def set_existing_invitee
    self.invitee ||= StudentAccount.find_by(email: invitee_email)
    true
  end
end
