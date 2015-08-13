class UpdateUsers < ActiveRecord::Migration
  def change
    add_column :users, :activation_token, :string
    remove_column :users, :email_activation
  end
end
