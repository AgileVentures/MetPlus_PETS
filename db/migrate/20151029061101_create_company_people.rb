class CreateCompanyPeople < ActiveRecord::Migration
  def change
    create_table :company_people do |t|
      t.belongs_to :company, index: true, foreign_key: true
      t.belongs_to :address, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
