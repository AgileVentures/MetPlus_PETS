class CreateJoinTableAgencyCompany < ActiveRecord::Migration
  def change
    create_join_table :agencies, :companies do |t|
      # t.index [:agency_id, :company_id]
      # t.index [:company_id, :agency_id]
    end
  end
end
