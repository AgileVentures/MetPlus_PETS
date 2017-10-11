class CreateJobQuestions < ActiveRecord::Migration
  def change
    create_table :job_questions do |t|
      t.references :job, index: true, foreign_key: true
      t.references :question, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
