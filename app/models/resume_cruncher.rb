class ResumeCruncher
  include ActiveModel::Model

  # This provides functionality that mediates between the ResumeCruncher service
  # and other models and controllers, for example:
  # > store a résumé file uploaded from a form,
  # > retrieve a résumé file
  # > retrieve a list of jobs matching a résumé
  # > retrieve a list of résumés matching a job

  def self.upload_resume(file, file_name, user_id)
    
    # Returns true if success, false otherwise
    CruncherService.upload_file(file, file_name, user_id)
  end

end
