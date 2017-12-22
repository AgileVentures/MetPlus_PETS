include ActionDispatch::TestProcess

FactoryBot.define do
  factory :resume do
    file_name 'Janitor-Resume.doc'
    job_seeker
    file { File.new("#{Rails.root}/spec/fixtures/files/Janitor-Resume.doc") }
  end
end
