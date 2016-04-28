class AddJobEmailToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :job_email, :string
  end
end
