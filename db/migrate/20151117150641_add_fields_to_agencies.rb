class AddFieldsToAgencies < ActiveRecord::Migration
  def change
    add_column :agencies, :fax, :string
    add_column :agencies, :description, :text
  end
end
