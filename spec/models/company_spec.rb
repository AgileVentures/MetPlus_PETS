require 'rails_helper'

RSpec.describe Company, type: :model do

  describe 'Fixtures' do
    it 'should have a valid factory' do
      expect(FactoryGirl.build(:company)).to be_valid
    end
  end

  describe 'Associations' do
    it { is_expected.to have_many :company_people }
    it { is_expected.to have_many :addresses }
    it { is_expected.to have_many :jobs }
    it { is_expected.to have_and_belong_to_many :agencies }
    it { is_expected.to accept_nested_attributes_for(:addresses).
                              allow_destroy(true) }
    it { is_expected.to have_many(:status_changes) }
  end

  describe 'Database schema' do
    it { is_expected.to have_db_column :id }
    it { is_expected.to have_db_column :name }
    it { is_expected.to have_db_column :ein }
    it { is_expected.to have_db_column :phone }
    it { is_expected.to have_db_column :fax }
    it { is_expected.to have_db_column :email }
    it { is_expected.to have_db_column :website }
    it { is_expected.to have_db_column :job_email }
    it { is_expected.to have_db_column :status }
  end

   describe 'Validation' do

     describe 'EIN' do
       subject {FactoryGirl.build(:company)}
       it { should_not allow_value('asd', '123456', '123-456789',
               '12-34567891', '00-0000000', '000000000').for(:ein) }

       it { should allow_value('12-3456789', '123456789').for(:ein) }
       it { is_expected.to validate_presence_of(:ein).
                with_message('is missing') }
       it { is_expected.to validate_uniqueness_of(:ein).case_insensitive.
                with_message('has already been registered')}
     end

     describe 'phone' do
       subject {FactoryGirl.build(:company)}
       it { should_not allow_value('asd', '123456', '123 1231  1234', '1    123 123 1234',
               ' 123 123 1234', '(234 1234 1234', '786) 1243 3578').for(:phone)}
       it { should allow_value('+1 123 123 1234', '123 123 1234', '(123) 123 1234',
               '1 231 231 2345', '12312312345',  '1231231234',
               '1-910-123-9158 x2851', '1-872-928-5886', '833-638-6551 x16825').for(:phone)}
     end

     describe 'fax' do
       subject {FactoryGirl.build(:company)}
       it { should_not allow_value('asd', '123456', '123 1231  1234', '1    123 123 1234',
               ' 123 123 1234', '(234 1234 1234', '786) 1243 3578').for(:fax)}
       it { should allow_value('+1 123 123 1234', '123 123 1234', '(123) 123 1234',
               '1 231 231 2345', '12312312345',  '1231231234',
               '1-910-123-9158 x2851', '1-872-928-5886', '833-638-6551 x16825').for(:fax)}
     end

     describe 'Email' do
       let!(:company) {FactoryGirl.build(:company)}
       it do
         stub_email_validate_error
         company.email = 'asd'
         expect(company).not_to be_valid
         company.email = 'john@company'
         expect(company).not_to be_valid
       end
       it { should allow_value('johndoe@company.com').for(:email)}
     end


     describe 'Website' do
       subject {FactoryGirl.build(:company)}
       it { should_not allow_value('asd', 'ftp://company.com', 'http:',
                 'http://','https',  'https:', 'https://',
                 'http://place.com###Bammm').for(:website)}

       it { should allow_value('http://company.com',
                               'https://company.com',
                               'http://w.company.com/info',
                               'https://comp.com:10/test/1/wasd',
                               'http://company.com/').for(:website)}
     end

     describe 'Name check' do
       subject {FactoryGirl.build(:company)}
       it { is_expected.to validate_presence_of :name }
     end

     describe 'Job Email' do
       it { should validate_presence_of(:job_email) }
       it do
         stub_email_validate_error
         should_not allow_value('asd', 'john@company').for(:job_email)
       end
       it { should allow_value('johndoe@company.com').for(:job_email)}
     end

     describe 'status' do
        it 'Status -1 should generate exception' do
          expect{subject.status = -1}.to raise_error(ArgumentError).with_message('\'-1\' is not a valid status')
        end
        it 'Status 0 should be pending_registration' do
          subject.status = 0
          expect(subject.status).to eq 'pending_registration'
        end
        it 'Status 1 should be active' do
          subject.status = 1
          expect(subject.status).to eq 'active'
        end
        it 'Status 2 should be inactive' do
          subject.status = 2
          expect(subject.status).to eq 'inactive'
        end
        it 'Status 3 should be registration_denied' do
          subject.status = 3
          expect(subject.status).to eq 'registration_denied'
        end
        it 'Status 4 should generate error' do
          expect{subject.status = 4}.to raise_error(ArgumentError).with_message('\'4\' is not a valid status')
        end
     end

   end



end
