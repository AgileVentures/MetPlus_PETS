require 'rails_helper'

class TestConcernCompanyPeopleClass
  extend CompanyPeopleViewer
end

RSpec.describe CompanyPeopleViewer do
  describe '#display_company_people' do
    let(:no_company_people)  {{pets_user: '',
                               full_name: '',
                               email: 'bob@hrsolutions.com',
                               phone: '011 555 555',
                               roles: 'Admin',
                               status: 'Active',
                               company: 'HR Soultions'}}
    it 'no company people present' do
    expect(TestConcernCompanyPeopleClass.display_company_people no_company_people).to eq(
                               email: 'bob@hrsolutions.com',
                               phone: '011 555 555',
                               roles: 'Admin',
                               status: 'Active',
                               company: 'HR Soultions')
  end
  end
end
