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

end
