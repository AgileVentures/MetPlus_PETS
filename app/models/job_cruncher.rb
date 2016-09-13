class JobCruncher
  include ActiveModel::Model

  # This provides functionality that mediates between the Cruncher service and other models and controllers.
  def self.create_job(jobId, title, description)
    # Returns true if success, false otherwise

     CruncherService.create_job(jobId, title, description)
  end

  def self.match_jobs(resumeId)
    # If match exists, returns a hash of job matches where each
    # key is job id (integer) and value is the score of the job
    # match to the résumé (float - one digit to right of decimal point).
    # Otherwise returns nil(in case of resume not found)

    # Example return value:
    # {3 => 2.1, 5 => 3.3, 8 => 4.7}
    # Job (ID) 3 matched résumé with a score of 2.1, job 5 with 3.3, etc.

    # Note that the results are not sorted in any order (keys or values)

    match_results = CruncherService.match_jobs(resumeId)

    matching_jobs = {}

    # First level of results is a hash of specific matcher results ....
    match_results.each_value do |matcher|
      # Second level is array of job matching scores (hashes) ....
      matcher.each do |job_match|
        job_id = job_match['jobId'].to_i

        # Have we seen this job from another matcher?
        # If so, use highest score
        if matching_jobs[job_id]
          matching_jobs[job_id] = job_match['stars'] if
          matching_jobs[job_id] < job_match['stars']
        else
          matching_jobs[job_id] = job_match['stars']
        end
      end
    end

    matching_jobs
  end
end
