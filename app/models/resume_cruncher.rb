class ResumeCruncher
  include ActiveModel::Model

  # This provides functionality that mediates between the Cruncher service
  # and other models and controllers, for example:
  # > store a résumé file uploaded from a form,
  # > retrieve a résumé file
  # > retrieve a list of jobs matching a résumé
  # > retrieve a list of résumés matching a job

  def self.upload_resume(file, file_name, file_id)

    # Returns true if success, false otherwise
    CruncherService.upload_file(file, file_name, file_id)
  end

  def self.download_resume(file_id)
    # Returns Tempfile instance if success, nil otherwise
    # NOTE: Caller is responsible for deleting tempfile (#unlink)

    CruncherService.download_file(file_id)
  end

  def self.match_resumes(job_id)
    # If match exists, returns a hash of résumé matches where each
    # key is résumé id (integer) and value is the score of the résumé
    # match to the job (float - one digit to right of decimal point).
    # Otherwise returns nil (in case of job not found)

    # Example return value:
    # {3 => 2.1, 5 => 3.3, 8 => 4.7}
    # Résumé (ID) 3 matched job with a score of 2.1, résumé 5 with 3.3, etc.

    # Note that the results are not sorted in any order (keys or values)

    match_results = CruncherService.match_resumes(job_id)

    matching_resumes = {}

    # First level of results is a hash of specific matcher results ....
    match_results.each_value do |matcher|
      # Second level is array of resume matching scores (hashes) ....
      matcher.each do |resume_match|
        resume_id = resume_match['resumeId'].to_i

        # Have we seen this job from another matcher?
        # If so, use highest score
        if matching_resumes[resume_id]
          matching_resumes[resume_id] = resume_match['stars'] if
          matching_resumes[resume_id] < resume_match['stars']
        else
          matching_resumes[resume_id] = resume_match['stars']
        end
      end
    end

    matching_resumes
  end

end
