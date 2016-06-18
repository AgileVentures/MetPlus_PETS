require 'rails_helper'

class TestJobseekClass
  extend JobSeekersViewer
end

RSpec.describe JobSeekersViewer do
  describe 'display_job_seekers' do
   let(:case_manager) {FactoryGirl.create(:case_manager)}
   let(:job_seeker) {FactoryGirl.create(:job_seeker)}
   #let(:with_attributes)  {{:people_type => 'jobseeker-cm', :per_page => 10,
                           #:agency_person => case_manager}}
   #let(:with_attributes)  {{:people_type =>'jobseeker-cm',:agency_person =>case_manager, :per_page => 10}}                           
   
   it 'collect  jobseeker assigned to case manager' do
     byebug
      job_seeker.assign_case_manager(case_manager,case_manager.agency)

      expect(TestJobseekClass.display_job_seekers('jobseeker-cm',case_manager )).to include job_seeker
      #expect(TestJobseekClass.display_job_seekers with_attributes).to include job_seeker
   end
  end
  
end


 
