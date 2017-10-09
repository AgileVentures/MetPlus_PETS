class AddOrgToSkills < ActiveRecord::Migration
  def change
    add_column :skills, :organization_type, :string
    add_column :skills, :organization_id, :integer
  end
end
