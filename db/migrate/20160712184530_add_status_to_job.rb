class AddStatusToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :status, :string,
                      default: Job::STATUS[:ACTIVE]
  end
end
