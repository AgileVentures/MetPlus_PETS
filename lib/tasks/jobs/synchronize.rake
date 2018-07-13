namespace :jobs do
  desc 'Synchronize jobs from the application database to the cruncher'
  task synchronize: :environment do
    Jobs::SynchronizeCruncher.new.call
  end
end
