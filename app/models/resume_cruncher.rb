class ResumeCruncher
  include ActiveModel::Model
  include CruncherUtility

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
    # If match exists, returns an array of résumé matches.  Each match
    # is represented as an array with 2 values - the first value is
    # the résumé ID, and the second the match score (a float, with
    # one digit to right of decimal point).
    # Otherwise returns nil(in case of job not found)

    # The array is sorted by score (descending)

    # Example return value:
    # [ [8, 4.7], [5, 3.3], [3, 2.1] ]
    # Résumé (ID) 8 matched job with a score of 4.7, résumé 5 with 3.3, etc.

    match_results = CruncherService.match_resumes(job_id)

    self.process_match_results match_results, 'resumeId'
  end

end
