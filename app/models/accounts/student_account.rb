class StudentAccount < Account
  default_scope { joins(:student_profile) }

  after_initialize :build_student_profile, if: -> { student_profile.blank? }

  has_many :memberships, as: :member, dependent: :destroy
  has_many :mentor_invites, foreign_key: :inviter_id

  has_many :join_requests, as: :requestor

  has_one :parental_consent, dependent: :destroy, foreign_key: :account_id

  has_one :student_profile, dependent: :destroy, foreign_key: :account_id
  accepts_nested_attributes_for :student_profile
  validates_associated :student_profile

  delegate :is_in_secondary_school?,
           :is_in_secondary_school,
           :parent_guardian_email,
           :parent_guardian_name,
           :school_name,
           :completion_requirements,
    to: :student_profile,
    prefix: false

  delegate :electronic_signature,
           :signed_at,
    to: :parental_consent,
    prefix: true

  def is_on_team?
    teams.any?
  end

  def requested_to_join?(team)
    join_requests.flat_map(&:joinable).include?(team)
  end

  def team
    teams.first
  end

  def team_id
    team.id
  end

  def team_name
    team.name
  end

  def team_names
    teams.collect(&:name)
  end

  def teams
    Team.joins(:memberships).where("memberships.member_id = ?", id)
  end

  def invited_mentor?(mentor)
    mentor_invites.flat_map(&:invitee).include?(mentor)
  end
end
