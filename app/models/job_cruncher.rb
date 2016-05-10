class JobCruncher
  include ActiveModel::Model

  # This provides functionality that mediates between the Cruncher service and other models and controllers.
  def self.create_job(jobId, title, description)
    # Returns true if success, false otherwise

     CruncherService.create_job(jobId, title, description)
  end
end

