class Score < ActiveRecord::Base
  default_scope { includes(:score_values) }

  belongs_to :judge
  belongs_to :submission
  has_one :team, through: :submission
  has_and_belongs_to_many :score_values


  delegate :name, to: :team, prefix: true

  def total
    score_values.total
  end

  def score_value_selected?(score_value)
    score_value_ids.include?(score_value.id)
  end
end
