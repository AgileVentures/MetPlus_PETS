class UpdateJobSeekerStatusValueField < ActiveRecord::Migration
	def change
		change_table :job_seeker_statuses do |t|
			t.rename :value, :key
			t.string :short_description
		end

		[
			{:key => 'UNEMPLOYERLOOKING',
				:short_description => 'Unemployed Seeking',
				:description => 'A jobseeker Without any work and looking for a job.'},
			{:key => 'EMPLOYERLOOKING',
				:short_description => 'Employed Looking',
				:description => 'A jobseeker with a job and looking for a job.'},
			{:key => 'EMPLOYERNOTLOOKING',
				:short_description => 'Employer Not Looking',
				:description => 'A jobseeker with a job and not looking for a job for now.'}
		].each do |values|
			execute "insert into job_seeker_statuses " +
													 "(key, short_description, description, created_at, updated_at) " +
										"values ('#{values[:key]}', " +
														"'#{values[:short_description]}', " +
														"'#{values[:description]}'," +
														"'#{Time.now}', " +
														"'#{Time.now}')"
		end

		change_table :job_seekers do |t|
			t.remove :job_seeker_statuses
			t.string :status
		end
	end
end
