class AddOrgToSkills < ActiveRecord::Migration
  def up
    change_table :skills do |t|
      t.column :organization_type, :string
      t.column :organization_id, :integer
    end

    agency = Agency.first

    Skill.all.each do |skill|
      skill.organization = agency
      skill.save
    end
  end

  def down
    change_table :skills do |t|
      t.remove :organization_type
      t.remove :organization_id
    end
  end
end
