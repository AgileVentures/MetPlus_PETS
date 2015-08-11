class JobSkill < ActiveRecord::Base
  belongs_to :job
  belongs_to :skill
end
