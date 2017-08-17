require 'csv'

namespace :job_skills do
  task import_generic: :environment do
    count = 0
    CSV.foreach("#{Rails.root}/lib/seeds/job_skills.csv", headers: :true) do |row|
      unless Skill.where('name = ? AND description = ?', row[0], row[1]).any?
        Skill.create!(name: row[0], description: row[1])
        count += 1
      end
    end
    puts "#{count} generic skills uploaded"
  end
end
