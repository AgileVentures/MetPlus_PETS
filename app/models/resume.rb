class Resume < ActiveRecord::Base
  belongs_to :job_seeker

  attr_accessor :file  # File uploaded from form

  validates_presence_of :file, on: :create
  validates_presence_of :file_name, :job_seeker_id

  # Valid file types for résumé files:
  FILETYPES = ['pdf', 'doc', 'docx']

  def initialize(file: nil, file_name: nil, job_seeker_id: nil)
    super

    # attribute 'file' is not persisted so will not be handled by super
    self.file = file
  end

  def save
    return false if not valid? or not super
    begin
      return true if ResumeCruncher.upload_resume(file, file_name, id)
    rescue
      errors.add(:file, 'could not be uploaded - see system admin')
      destroy
      raise
    end
  end
end
