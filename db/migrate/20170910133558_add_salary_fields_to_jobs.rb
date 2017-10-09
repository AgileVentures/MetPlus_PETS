class AddSalaryFieldsToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :max_salary, :decimal, precision: 8, scale: 2
    add_column :jobs, :min_salary, :decimal, precision: 8, scale: 2
    add_column :jobs, :pay_period, :string
  end
end
