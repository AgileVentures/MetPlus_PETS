class AddDescriptionToCompany < ActiveRecord::Migration
  def change
    remove_column :companies, :description
    add_column :companies, :description, :text
  end
end
