class AddAdministratorToUser < ActiveRecord::Migration
  def change
    add_column :users, :administrator, :boolean, default: false
  end
end
