class CreateJoinTableAgencyPersonJobCategory < ActiveRecord::Migration
  def change
    create_join_table :agency_people, :job_categories,
                           table_name: :job_specialities do |t|
      # t.index [:agency_person_id, :job_category_id]
      # t.index [:job_category_id, :agency_person_id]
    end
  end
end
