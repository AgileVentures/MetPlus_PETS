require 'rails_helper'


RSpec.describe CompanyPolicy do
  let(:agency) { FactoryGirl.create(:agency)}
  let(:admin)  { FactoryGirl.create(:agency_admin, agency: agency)}
  let(:jd)     { FactoryGirl.create(:job_developer, agency: agency)}
  let(:cm)     { FactoryGirl.create(:case_manager,  agency: agency)}
  let(:company){ FactoryGirl.create(:company, agencies: [agency])}
  let(:ca)     { FactoryGirl.create(:company_admin, company: company)}
  let(:cc)     { FactoryGirl.create(:company_contact, company: company)}
  let(:js)     { FactoryGirl.create(:job_seeker)}


 permissions :edit?, :update?, :show? do
   
    it 'denies access if user is not agency admin' do
       expect(CompanyPolicy).not_to permit(jd, company)
    end
   
    
    it 'denies access if user is not agency admin' do
       expect(CompanyPolicy).not_to permit(cc, company)
    end


    it 'allows access if user is an agency admin' do
      expect(CompanyPolicy).to permit(admin, company)
    end

    
    it 'allows access if user is an company admin' do
      expect(CompanyPolicy).to permit(ca, company)
    end

 end

end




  
