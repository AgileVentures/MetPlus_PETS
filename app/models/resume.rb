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
    return true if ResumeCruncher.upload_resume(file, file_name, id)

    errors.add(:file, 'could not be uploaded - see system admin')
    destroy
    false
  end

  # private
  #
  # def upload_resume
  #   # 'file' is a Ruby File object
  #   # file type must confirm to acceptable file types defined above
  #   ResumeCruncher.upload_resume(file, file_name, job_seeker_id)
  # end
end
