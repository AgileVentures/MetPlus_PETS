class CreateTasks < ActiveRecord::Migration
  def change
    create_table :task_settings do |t|
      t.string  :short_name
      t.string  :description
      t.integer :display_in
      t.string  :targets

      t.timestamps null: false
    end

    TaskSetting.new(:short_name => "INACTIVEJS", :description => "The Job Seeker is inactive!",
                    :display_in => 15, :targets => "JD,CM")
    TaskSetting.new(:short_name => "JSRESUMEALREADYSENT", :description => "The Job Seeker resume was sent",
                    :display_in => -1, :targets => "JD")
    TaskSetting.new(:short_name => "NOJSASSIGNED", :description => "The Job Seeker do not have a Job Developer",
                    :display_in => -1, :targets => "JD")
    TaskSetting.new(:short_name => "NOCMASSIGNED", :description => "The Job Seeker do not have a Case Manager",
                    :display_in => -1, :targets => "CM")
    TaskSetting.new(:short_name => "SELFAPPLY", :description => "The Job Seeker applied to a job",
                    :display_in => -1, :targets => "CM,JD")
    TaskSetting.new(:short_name => "APPLICATIONREJECTED", :description => "The Job Seeker application rejected",
                    :display_in => -1, :targets => "JS,JD,CM")
    TaskSetting.new(:short_name => "EMPLOYERCONTACTEDJS", :description => "The Job Seeker contacted by employer",
                    :display_in => -1, :targets => "JS")
    TaskSetting.new(:short_name => "EMPLOYERNOANWER", :description => "The Employer did not answer Job Seeker application",
                    :display_in => 15, :targets => "JD")
    TaskSetting.new(:short_name => "NEWJOB", :description => "New job posted",
                    :display_in => -1, :targets => "JD")
    TaskSetting.new(:short_name => "EMPLOYERALREADYINBRANCH", :description => "The Employer already exists in this agency branch",
                    :display_in => -1, :targets => "JD")


    create_table :tasks do |t|
      t.belongs_to :task_setting, index: true
      t.references :owner_user
      t.references :owner_agency
      t.string     :owner_agency_role
      t.references :owner_company
      t.string     :owner_company_role
      t.datetime   :deferred_date
      t.references :user
      t.references :job
      t.references :company

      t.timestamps null: false
    end
  end
end
