class AddYearsOfExperieceToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :years_of_experience, :integer, null: :true
  end
end
