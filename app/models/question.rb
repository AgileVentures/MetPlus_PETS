class Question < ApplicationRecord
  has_many :job_questions
  has_many :jobs, through: :job_questions, dependent: :destroy

  has_many :application_questions
  has_many :job_applications, through: :application_questions, dependent: :destroy

  validates_presence_of :question_text
end
