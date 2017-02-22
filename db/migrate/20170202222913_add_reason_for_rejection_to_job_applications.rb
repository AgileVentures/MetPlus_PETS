class AddReasonForRejectionToJobApplications < ActiveRecord::Migration
  def change
    add_column :job_applications, :reason_for_rejection, :string
  end
end
