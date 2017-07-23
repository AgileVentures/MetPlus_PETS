class DropCompanyPersonIndexFromJobs < ActiveRecord::Migration
  def change
    remove_index :jobs, column: :company_person_id
    remove_foreign_key :jobs, column: :company_person_id    
  end
end
