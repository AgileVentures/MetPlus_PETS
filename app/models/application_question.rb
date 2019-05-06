class ApplicationQuestion < ApplicationRecord
  belongs_to :job_application
  belongs_to :question

  validates_presence_of :job_application, :question

  validates_inclusion_of :answer, in: [true, false]
end
