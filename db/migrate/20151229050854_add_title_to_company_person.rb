class AddTitleToCompanyPerson < ActiveRecord::Migration
  def change
    add_column :company_people, :title, :string
  end
end
