class AddAddressToUsers < ActiveRecord::Migration
  def up
    change_table :job_seekers do |t|
      t.references :address, index: true, foreign_key: true
    end
    JobSeeker.all
  end
  def down
    change_table :job_seekers do |t|
      t.remove     :address_id
    end
  end
end
