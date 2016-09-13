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
    # If a match exists, returns a hash of resume matches where
    # key is the matcher id and value is the array of resume ids
    # If no match exists, returns as an empty hash

    # Example return value from CruncherService:
    # { "matcher2": [3, 2], "matcher1": [1, 2] }
    # Note that the keys returned are 'matcher1' and 'matcher2'
    # In the current version of API, we have a single matcher - Word Count
    # In future releases, additional matchers will be implemented and
    # the keys might also be modified to reflect the matcher used like
    # { "expressionCruncher": [3, 2], "naiveBayes": [1, 2] }
    # The caller can make use of the keys if required

    CruncherService.match_resumes(job_id)
  end

end
