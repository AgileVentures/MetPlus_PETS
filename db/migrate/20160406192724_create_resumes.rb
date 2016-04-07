class CreateResumes < ActiveRecord::Migration
  def change
    create_table :resumes do |t|
      t.string :file_name
      t.references :job_seeker, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
