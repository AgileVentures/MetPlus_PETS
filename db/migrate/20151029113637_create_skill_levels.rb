class CreateSkillLevels < ActiveRecord::Migration
  def change
    create_table :skill_levels do |t|
      t.string :name
      t.string :description

      t.timestamps null: false
    end
  end
end
