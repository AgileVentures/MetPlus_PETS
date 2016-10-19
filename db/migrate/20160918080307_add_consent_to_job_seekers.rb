class AddConsentToJobSeekers < ActiveRecord::Migration
  def up
    add_column :job_seekers, :consent, :boolean, default: true
  end
  
  def down
    remove_column :job_seekers, :consent
  end
end
