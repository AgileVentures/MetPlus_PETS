class CreateCompanyPeopleCompanyRolesJoin < ActiveRecord::Migration
  def change
    create_table :company_people_roles, id: false do |t|
    	t.integer :company_person_id
    	t.integer :company_role_id
    end
  end
end
