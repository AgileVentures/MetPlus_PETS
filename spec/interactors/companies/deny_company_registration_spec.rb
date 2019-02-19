require 'rails_helper'

class TestTaskHelper
  include TaskManager::BusinessLogic
  include TaskManager::TaskManager
end

RSpec.describe Companies::DenyCompanyRegistration do
  describe '#call' do
    let!(:agency) { FactoryBot.create(:agency) }
    let!(:company) do
      FactoryBot.create(:company, id: 100, status: 'pending_registration')
    end
    let!(:company_person) do
      FactoryBot.create(:pending_first_company_admin, company: company)
    end

    context 'when the company is denied' do
      before(:each) do
        TestTaskHelper.new_review_company_registration_task(company, agency)
        allow(Event).to receive(:create)
        subject.call(company, 'error')
      end

      it 'changes the state of the company to "registration_denied"' do
        expect(Company.find(100).registration_denied?).to be(true)
      end

      it 'create a "Company Denied" event' do
        save_company = Company.find(100)
        expect(Event).to have_received(:create)
          .with(
            :COMP_DENIED,
            have_attributes(company: save_company, reason: 'error')
          )
      end

      it 'completes pending_registration Task' do
        expect(Task.all.length).to be 1
        expect(Task.all.first.status)
          .to eq TaskManager::TaskManager::STATUS[:DONE]
      end
    end
  end
end
