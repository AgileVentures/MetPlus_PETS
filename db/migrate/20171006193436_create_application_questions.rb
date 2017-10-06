class CreateApplicationQuestions < ActiveRecord::Migration
  def change
    create_table :application_questions do |t|
      t.references :job_application, index: true, foreign_key: true
      t.references :question, index: true, foreign_key: true
      t.boolean :answer

      t.timestamps null: false
    end
  end
end
