class AddEducationInfoToJob < ActiveRecord::Migration
  def change
    add_column :jobs, :education_info, :string
    add_reference :jobs, :education, index: true, foreign_key: true
  end
end
