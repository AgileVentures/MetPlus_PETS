class JobCruncher
  include ActiveModel::Model
  include CruncherUtility

  # This provides functionality that mediates between the Cruncher service
  # and other models and controllers.

  def self.create_job(job_id, title, description)
    # Returns true if success, false otherwise

    CruncherService.create_job(job_id, title, description)
  end

  def self.update_job(job_id, title, description)
    # Returns true if success, false otherwise

    CruncherService.update_job(job_id, title, description)
  end

  def self.update_job(job_id, title, description)
    # Returns true if success, false otherwise

    CruncherService.update_job(job_id, title, description)
  end

  def self.match_jobs(resume_id)
    # If match exists, returns an array of job matches.  Each match
    # is represented as an array with 2 values - the first value is
    # the job ID, and the second the match score (a float, with
    # one digit to right of decimal point).
    # Otherwise returns nil(in case of resume not found)

    # The array is sorted by score (descending)

    # Example return value:
    # [ [8, 4.7], [5, 3.3], [3, 2.1] ]
    # Job (ID) 8 matched resume with a score of 4.7, job 5 with 3.3, etc.

    match_results = CruncherService.match_jobs(resume_id)

    process_match_results match_results, 'jobId'
  end
end
