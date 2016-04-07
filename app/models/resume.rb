class Resume < ActiveRecord::Base
  belongs_to :job_seeker

  attr_accessor :file  # File uploaded from form

  validates_presence_of :file, on: :create

  # Valid file types for résumé files:
  FILETYPES = ['pdf', 'doc', 'docx']

  def initialize(*args)
    # attribute 'file' is not persisted so will not be handled by super
    self.file = args[0].delete :file if not args.empty?
    super
  end

  def save
    return false if not valid? or not super
    return true if upload(file, file_name, job_seeker_id)

    errors.add(:file, 'could not be uploaded - see system admin')
  end

  private

  def self.upload(file, user_id)
    # 'file' is a Ruby File object
    # file type must confirm to acceptable file types defined in Resume model
    ResumeCruncher.upload_resume(file, file_name, user_id)
  end
end
