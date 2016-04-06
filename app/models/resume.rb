class Resume < ActiveRecord::Base
  belongs_to :job_seeker

  # Valid file types for résumé files:
  FILETYPES = ['pdf', 'doc', 'docx']
  
end
