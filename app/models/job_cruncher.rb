class JobCruncher
  include ActiveModel::Model

  # This provides functionality that mediates between the Cruncher service and other models and controllers.
  def self.create_job(jobId, title, description)
    # Returns true if success, false otherwise

     CruncherService.create_job(jobId, title, description)
  end

  def self.match_jobs(resumeId)
    # If match exists, returns a hash of job matches where
    # key is the matcher id and value is the array of job ids
    # Otherwise returns nil(in case of resume not found)

    # Example return value from Cruncher Service:
    # { "matcher2": [3, 2], "matcher1": [1, 2] }
    # Note that the keys returned are 'matcher1' and 'matcher2'
    # In the current version of API, we have a single matcher - Word Count
    # In future releases, additional matchers will be implemented and
    # the keys might also be modified to reflect the matcher used likely
    # { "expressionCruncher": [3, 2], "naiveBayes": [1, 2] }
    # The caller can make use of the keys if required

    CruncherService.match_jobs(resumeId)
  end
end
