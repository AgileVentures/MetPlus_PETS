class AddAddressRefToJobs < ActiveRecord::Migration
  def change
    add_reference :jobs, :address, index: true, foreign_key: true
  end
end
