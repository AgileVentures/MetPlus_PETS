class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string    :type
      t.references :target_user
      t.references :target_agency
      t.string :target_agency_role
      t.references :target_company
      t.string :target_company_role
      t.datetime  :deferred_date
      t.references :user
      t.references :job
      t.references :company

      t.timestamps null: false
    end
  end
end
