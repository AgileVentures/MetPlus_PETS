class RemoveActAs < ActiveRecord::Migration
  def change
    add_column :job_seekers, :user_id, :integer
    add_column :agency_people, :user_id, :integer
    add_column :company_people, :user_id, :integer
    User.all.each do |user|
      pets_user = nil
      if user.actable_type == 'JobSeeker'
        pets_user = JobSeeker.find_by_id(user.actable_id)
      elsif user.actable_type == 'AgencyPerson'
        pets_user = AgencyPerson.find_by_id(user.actable_id)
      elsif user.actable_type == 'CompanyPerson'
        pets_user = CompanyPerson.find_by_id(user.actable_id)
      end
      pets_user.user_id = user.id
      pets_user.save!
    end
    remove_column :users, :actable_id
    remove_column :users, :actable_type
    
    add_foreign_key :job_seekers, :users
    add_foreign_key :agency_people, :users
    add_foreign_key :company_people, :users
  end
end
