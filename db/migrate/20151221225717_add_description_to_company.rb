class AddDescriptionToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :description, :text
  end
end
