class JobSkill < ApplicationRecord
  belongs_to :job, inverse_of: :job_skills
  belongs_to :skill, counter_cache: :jobs_count

  validates_presence_of :job, :skill
  validates_uniqueness_of :skill_id, scope: :job_id

  validates :required, inclusion: { in: [true, false] }
  validates_numericality_of :min_years, only_integer: true,
                                        greater_than_or_equal_to: 0,
                                        less_than_or_equal_to: 15,
                                        allow_nil: true
  validates_numericality_of :max_years, only_integer: true,
                                        greater_than_or_equal_to: 0,
                                        less_than_or_equal_to: 50,
                                        allow_nil: true
end
