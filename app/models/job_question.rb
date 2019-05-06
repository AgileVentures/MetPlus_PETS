class JobQuestion < ApplicationRecord
  belongs_to :job
  belongs_to :question
end
