class AddStatusToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :status, :string,
                      default: Company::STATUS[:PND]
  end
end
