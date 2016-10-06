class AddStatusToCompanyPeople < ActiveRecord::Migration
  def change
    add_column :company_people, :status, :string, default: 'Active'
  end
end
