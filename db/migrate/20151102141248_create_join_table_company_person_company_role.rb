class CreateJoinTableCompanyPersonCompanyRole < ActiveRecord::Migration
  def change
    create_join_table :CompanyPeople, :CompanyRoles do |t|
      # t.index [:company_person_id, :company_role_id]
      # t.index [:company_role_id, :company_person_id]
    end
  end
end
