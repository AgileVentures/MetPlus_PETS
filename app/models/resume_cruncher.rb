# Interfaces to Cruncher service API for resumes
class ResumeCruncher
  include ActiveModel::Model
  include CruncherUtility

  # This provides functionality that mediates between the Cruncher service
  # and other models and controllers, for example:
  # > store a resume file uploaded from a form,
  # > retrieve a resume file
  # > retrieve a list of jobs matching a resume
  # > retrieve a list of resumes matching a job

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
    # If match exists, returns an array of resume matches.  Each match
    # is represented as an array with 2 values - the first value is
    # the resume ID, and the second the match score (a float, with
    # one digit to right of decimal point).
    # Otherwise returns nil(in case of job not found)

    # The array is sorted by score (descending)

    # Example return value:
    # [ [8, 4.7], [5, 3.3], [3, 2.1] ]
    # Resume (ID) 8 matched job with a score of 4.7, resume 5 with 3.3, etc.

    match_results = CruncherService.match_resumes(job_id)
    process_match_results match_results, 'resumeId'
  end

  def self.match_resume_and_job(resume_id, job_id)
    # Returns a hash with 2 key-value pairs:
    # status:  'SUCCESS' or 'ERROR'
    # message: string indicating error cause (if status == ERROR)
    # score:   maximum match score across all matchers
    #              (float, n.m) (if status = SUCCESS)

    match_result = CruncherService.match_resume_and_job(resume_id, job_id)

    return { status: 'SUCCESS', score: match_result[:stars].values.max } if
                match_result[:status] == 'SUCCESS'

    { status: 'ERROR', message: match_result[:message] }
  end
end
