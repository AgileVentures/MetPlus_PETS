class UpdateJobSeekerStatusValueField < ActiveRecord::Migration
  def up
    change_table :job_seeker_statuses do |t|
      t.remove :value
      t.string :short_description
    end

    [
      { :short_description => 'Unemployed Seeking',
        :description => 'A jobseeker Without any work and looking for a job.'},
      { :short_description => 'Employed Looking',
        :description => 'A jobseeker with a job and looking for a job.'},
      { :short_description => 'Employed Not Looking',
        :description => 'A jobseeker with a job and not looking for a job for now.'}
    ].each do |values|
      execute "insert into job_seeker_statuses " +
                           "(short_description, description, created_at, updated_at) " +
                    "values ('#{values[:short_description]}', " +
                            "'#{values[:description]}'," +
                            "'#{Time.now}', " +
                            "'#{Time.now}')"
    end
  end
  def down
    change_table :job_seeker_statuses do |t|
      t.string :value
      t.remove :short_description
    end
  end
end
