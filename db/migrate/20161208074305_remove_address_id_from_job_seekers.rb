class RemoveAddressIdFromJobSeekers < ActiveRecord::Migration
  def change
    remove_column :job_seekers, :address_id, :integer
  end
end
