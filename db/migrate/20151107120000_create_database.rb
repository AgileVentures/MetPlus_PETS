class CreateDatabase < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :street
      t.string :city
      t.string :zipcode
      t.references :location, polymorphic: true
      t.timestamps null: false
    end
    create_table :skills do |t|
      t.string :name
      t.string :description

      t.timestamps null: false
    end
    create_table :users do |t|
      t.string :email, null: false, default: ""
      t.string :first_name
      t.string :last_name
      t.string :phone
      t.integer :actable_id
      t.string :actable_type

      ## Database authenticatable
      # t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer  :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string   :current_sign_in_ip
      t.string   :last_sign_in_ip

      ## Confirmable
      t.string   :confirmation_token
      t.datetime :confirmed_at
      t.datetime :confirmation_sent_at
      t.string   :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer  :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string   :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at


      # Uncomment below if timestamps were not included in your original model.
      # t.timestamps null: false

      t.timestamps null: false
    end

    add_index :users, :email            #,unique: true
    add_index :users, :reset_password_token, unique: true
    # add_index :users, :confirmation_token,   unique: true
    # add_index :users, :unlock_token,         unique: true

    ## Company tables
    create_table :companies do |t|
      t.string :name
      t.string :ein
      t.string :phone
      t.string :email
      t.string :website

      t.timestamps null: false
    end
    create_table :company_people do |t|
      t.belongs_to :company, index: true, foreign_key: true
      t.belongs_to :address, index: true, foreign_key: true
      t.timestamps null: false
    end

    ## Job
    create_table :job_categories do |t|
      t.string :name
      t.string :description

      t.timestamps null: false
    end

    create_table :jobs do |t|
      t.string :title
      t.string :description
      t.references :company, index: true, foreign_key: true
      t.references :company_person, index: true, foreign_key: true
      t.references :job_category, index: true, foreign_key: true

      t.timestamps null: false
    end

    ## Job Seeker
    create_table :job_seeker_statuses do |t|
      t.string :value
      t.text :description

      t.timestamps null: false
    end
    create_table :job_seekers do |t|
      t.string :year_of_birth
      t.belongs_to :job_seeker_status, index: true, foreign_key: true
      t.string :resume

      t.timestamps null: false
    end
    create_table :seekers_agency_people, id: false do |t|
      t.integer :agency_person_id
      t.integer :job_seeker_id
    end
    add_index :seekers_agency_people, [:agency_person_id, :job_seeker_id], :name => "seekersagencypeople"
    create_table :agencies do |t|
      t.string :name
      t.string :website
      t.string :phone
      t.string :email

      t.timestamps null: false
    end
    create_join_table :agencies, :companies do |t|
      # t.index [:agency_id, :company_id]
      # t.index [:company_id, :agency_id]
    end
    create_table :agency_people do |t|
      t.references :agency, index: true, foreign_key: true
      t.references :address, index: true, foreign_key: true

      t.timestamps null: false
    end
    create_table :skill_levels do |t|
      t.string :name
      t.string :description

      t.timestamps null: false
    end
    create_table :job_skills do |t|
      t.references :job, index: true, foreign_key: true
      t.references :skill, index: true, foreign_key: true
      t.references :skill_level, index: true, foreign_key: true
      t.boolean :required, default: false
      t.integer :min_years
      t.integer :max_years

      t.timestamps null: false
    end
    create_join_table :job_categories, :skills do |t|
      # t.index [:job_category_id, :skill_id]
      # t.index [:skill_id, :job_category_id]
    end
    create_table :agency_roles do |t|
      t.string :role

      t.timestamps null: false
    end
    create_join_table :agency_people, :agency_roles do |t|
      # t.index [:agency_person_id, :agency_role_id]
      # t.index [:agency_role_id, :agency_person_id]
    end
    create_join_table :agency_people, :job_categories,
                      table_name: :job_specialities do |t|
      # t.index [:agency_person_id, :job_category_id]
      # t.index [:job_category_id, :agency_person_id]
    end
    create_table :company_roles do |t|
      t.string :role
      t.timestamps null: false
    end
    create_table :company_people_roles, id: false do |t|
      t.integer :company_person_id
      t.integer :company_role_id
    end

  end
end
