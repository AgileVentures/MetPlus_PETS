class AddCompanyJobIdToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :company_job_id, :string
  end
end
