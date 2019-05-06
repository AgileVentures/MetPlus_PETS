class Resume < ApplicationRecord
  belongs_to :job_seeker

  attr_accessor :file # File uploaded from form

  validates_presence_of :file, on: :create
  validates_presence_of :file_name, :job_seeker_id
  validate :acceptable_file_type

  def acceptable_file_type
    return if not file_name

    mime_type = MIME::Types.type_for(URI.escape(file_name))
    # Below is using 'if not' since 'unless' construct does not
    # seem to short-circuit the rest of the statement with the
    # result that 'content_type' could be called on nil
    return if not mime_type.empty? and
              MIMETYPES.include? mime_type.first.content_type

    errors[:file_name] << 'unsupported file type'
  end

  # Valid MIME types for résumé files: pdf, doc, docx, pages
  MIMETYPES = [
    'application/pdf', 'application/msword',
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    'application/x-iwork-pages-sffpages'
  ]

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
    false
  end

  def save!
    super
    begin
      return true if ResumeCruncher.upload_resume(file, file_name, id)
    rescue
      destroy
      raise 'Resume could not be uploaded'
    end
  end
end
