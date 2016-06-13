class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string     :task_type
      t.references :owner_user
      t.references :owner_agency
      t.string     :owner_agency_role
      t.references :owner_company
      t.string     :owner_company_role
      t.datetime   :deferred_date
      t.references :user
      t.references :job
      t.references :company
      t.string     :status

      t.timestamps null: false
    end
  end
end
