class CreateCompanyRoles < ActiveRecord::Migration
  def change
    create_table :company_roles do |t|
      t.string :role

      t.timestamps null: false
    end
  end
end
