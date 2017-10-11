class Question < ActiveRecord::Base
  has_many :job_questions, dependent: :destroy
  has_many :jobs, through: :job_questions

  has_many :application_questions, dependent: :destroy
  has_many :job_applications, through: :application_questions

  validates_presence_of :question_text
end
