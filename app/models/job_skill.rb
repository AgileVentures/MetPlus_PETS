class JobSkill < ActiveRecord::Base
  belongs_to :job
  belongs_to :skill
  # belongs_to :skill_level

  validates_presence_of :job, :skill
  validates :required, inclusion: { in: [true, false] }
  validates_numericality_of :min_years, only_integer: true,
                      greater_than_or_equal_to: 0,
                      less_than_or_equal_to: 15
  validates_numericality_of :max_years, only_integer: true,
                      greater_than_or_equal_to: 0,
                      less_than_or_equal_to: 50
end
